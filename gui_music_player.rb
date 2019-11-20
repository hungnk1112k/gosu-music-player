require 'rubygems'
require 'gosu'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

module ZOrder
  BOTTOM, BACKGROUND, PLAYER, UI = *0..3
end


GENRE_NAMES = [ 'Pop', 'Classic', 'Jazz', 'Rap']

class ArtWork
	attr_accessor :bmp

	def initialize (file)
		@bmp = Gosu::Image.new(file)
	end
end

class Track
	attr_accessor :name, :location

	def initialize (name, location)
		@name = name
		@location = location
	end
end

class Album
	attr_accessor :title,:artist, :photo, :genre, :tracks

	def initialize (title, artist, photo, genre, tracks)
		@title = title
		@artist = artist
    @photo = photo
		@genre = genre
		@tracks = tracks
	end
end
# Put your record definitions here

class MusicPlayerMain < Gosu::Window
  WIDTH = 1000
  HEIGHT = 1000
	def initialize
	    super WIDTH, HEIGHT
	    self.caption = "Music Player"
      music_file = File.new("musicfile.txt", "r")
      @albums = read_albums(music_file)
      music_file.close()
      @font = Gosu::Font.new(40)
      @track_font = Gosu::Font.new(20)
      @album_chosen_index = 0
      @track_hover_index = 0
      @album_chosen = Album.new(0,0,0,0,[0,0])
      @album_play = Album.new(1,1,1,1,[1,1])
      @track_hover_photo = Gosu::Image.new('images/arrow.png')
      @track_click_photo = Gosu::Image.new('images/circle.png')
      @back = Gosu::Image.new('images/back.png')
      @front = Gosu::Image.new('images/front.png')
      @pause = Gosu::Image.new('images/pause.png')
      @play = Gosu::Image.new('images/play.png')
      @random = Gosu::Image.new('images/random.png')
      @restart = Gosu::Image.new('images/restart.png')
      @visible = false
      @visible_cicle = false
      @track_sort = :not_sorted
      @album_border = [ZOrder::PLAYER, ZOrder::BOTTOM, ZOrder::BOTTOM, ZOrder::BOTTOM]
      @menu_bar_color = [Gosu::Color::AQUA, Gosu::Color::GRAY, Gosu::Color::GRAY]
      @menu_option = [:menu, :genre, :favorite]
      @menu_index = 0
      @menu = @menu_option[@menu_index]
	end

  def read_albums(music_file)
    albums = Array.new()
    num_of_album = music_file.gets.chomp.to_i
    for i in 1..num_of_album
      album = read_album(music_file, i)
      albums << album
    end
    albums
  end

  def read_album(music_file, index)
    album_title = music_file.gets.chomp
    album_artist = music_file.gets.chomp
    album_photo = music_file.gets.chomp
    album_genre = music_file.gets.chomp.to_i
    tracks = read_tracks(music_file)
  	album = Album.new(album_title, album_artist, album_photo, album_genre, tracks)
  	album
  end

  def read_tracks(music_file)
    tracks = Array.new()
  	count = music_file.gets.to_i
  	for i in 1..count
      track = read_track(music_file)
      tracks << track
    end
  	tracks
  end

  def read_track(music_file)
    track_name = music_file.gets.chomp
  	track_location = music_file.gets.chomp
  	Track.new(track_name, track_location)
  end
  # Draws the artwork on the screen for all the albums

  def initialize_genre
    if !@genre_index
      @track_click_index_genre = 0
      @visible_cicle_genre = false
      @genre_bar_color = [Gosu::Color::AQUA, Gosu::Color::GRAY, Gosu::Color::GRAY, Gosu::Color::GRAY]
      @genre_option = []
      @track_sort_genre = :not_sorted
      @album_play_genre = Album.new(1,1,1,5,[1,1])
      for i in 0..3
        @genre_option << GENRE_NAMES[i]
      end
      @genre_index = 0
      @genre = @genre_option[@genre_index]
      @albums_by_genre = Array.new()
      for i in 0..GENRE_NAMES.length-1
        tracks = Array.new()
        for j in 0..@albums.length - 1
          if @albums[j].genre == i
            for k in 0..@albums[j].tracks.length - 1
              tracks << @albums[j].tracks[k]
            end
          end
        end
        album = Album.new(0, 0, 0, i, tracks)
        @albums_by_genre << album
      end
    end
  end

  def initialize_favorite
    if @favorite_index == nil
      @favorite_index = 0
      @favorite_bar_color = [Gosu::Color::AQUA, Gosu::Color::GRAY]
      @track_sort_favorite = :not_sorted
      @track_sort_add = :not_sorted
      @visible_cicle_favorite = false
      @track_click_index_favorite = 0
      @favorite = Array.new()
      @album_favorite = Album.new(0,0,0,0,@favorite)
      tracks = Array.new()
      for i in 0..@albums.length - 1
        for j in 0..@albums[i].tracks.length - 1
          tracks << @albums[i].tracks[j]
        end
      end
      @album_add = Album.new(0, 0, 0, 0, tracks)
    end
  end

  def draw
  		draw_quad(0,0,TOP_COLOR,WIDTH,0,TOP_COLOR,WIDTH,HEIGHT,BOTTOM_COLOR,0,HEIGHT,BOTTOM_COLOR, ZOrder::BACKGROUND)
      draw_menu_bar()
      draw_icon()
    case @menu
    when :menu
      draw_albums_photo(@albums)
      draw_album(@album_chosen_index)
      if @visible != false
        @track_hover_photo.draw(10, 420 + 50 * @track_hover_index ,2)
      end
      if @album_play != nil
        if @visible_cicle != false || @album_play.title == @album_chosen.title
          if @track_click_index != nil
            @track_click_photo.draw(10, 425 + 50 * @track_click_index ,2)
          end
        end
      end
    when :genre
      draw_genre_option()
      draw_genre_track()
      if @visible_genre != false
        @track_hover_photo.draw(10, 150 + 50 * @track_hover_index_genre ,2)
      end
      if @album_play_genre != nil
        if @visible_cicle_genre != false || @album_play_genre.genre == @genre_index
          @track_click_photo.draw(10, 155 + 50 * @track_click_index_genre ,2)
        end
      end
    when :favorite
      draw_favorite_option()
      draw_favorite_track()
      if @visible_favorite != false && @favorite_index == 0 && @track_hover_index_favorite != nil
        @track_hover_photo.draw(10, 125 + 50 * @track_hover_index_favorite ,2)
      end
      if @visible_add != false && @favorite_index == 1
        @track_hover_photo.draw(10, 125 + 50 * @track_hover_index_add ,2)
      end
      if @track_click_index_favorite != nil
        if @visible_cicle_favorite != false && @favorite_index == 0
          @track_click_photo.draw(10, 128 + 50 * @track_click_index_favorite ,2)
        end
      end
    end
  #  Gosu::Font.new(20).draw("mouse_x: #{mouse_x}", 0, 700, 1, 1.0, 1.0, Gosu::Color::BLACK)
  #  Gosu::Font.new(20).draw("mouse_y: #{mouse_y}", 0, 800, 1, 1.0, 1.0, Gosu::Color::BLACK)
	end

  def draw_albums_photo albums
    for i in 0..albums.length-1
      album_display = Gosu::Image.new(albums[i].photo)
      album_display.draw(25 + WIDTH * i / albums.length, 60,ZOrder::UI)
      Gosu.draw_rect(22 + WIDTH * i / albums.length, 57, 206, 206, Gosu::Color::BLACK, @album_border[i])
    end
  end

  def draw_album(index)
    @album_chosen = @albums[index]
    @font.draw("Album: #{@album_chosen.title}",20,270,1,1,1,Gosu::Color::BLACK)
    @font.draw("Artist: #{@album_chosen.artist}",500,270,1,1,1,Gosu::Color::BLACK)
    @font.draw("Genre: #{GENRE_NAMES[@album_chosen.genre]}",20,320,1,1,1,Gosu::Color::BLACK)
    @font.draw("Track list:",20,370,1,1,1,Gosu::Color::BLACK)
    for i in 0..@album_chosen.tracks.length-1
      @font.draw("#{i+1}. #{@album_chosen.tracks[i].name} ",40,420 + i * 50,1,1,1,Gosu::Color::BLACK)
    end
  end

  def draw_icon()
    @random.draw(220,920,2)
    @back.draw(280, 900 ,2)
    @restart.draw(380, 895 ,2)
    @play.draw(480, 900 ,2)
    @pause.draw(580, 895 ,2)
    @front.draw(680, 900 ,2)
    @font.draw("Sort track",600,500,ZOrder::UI,1,1,Gosu::Color::BLACK)
  end

  def draw_menu_bar
    for i in 0..2
      Gosu.draw_rect(325 * i + 25, 0, 300, 50, @menu_bar_color[i], ZOrder::PLAYER)
    end
    @font.draw("Main Menu",90,7,ZOrder::UI,1,1,Gosu::Color::BLACK)
    @font.draw("Songs by Genre",376,7,ZOrder::UI,1,1,Gosu::Color::BLACK)
    @font.draw("Favorite",760,7,ZOrder::UI,1,1,Gosu::Color::BLACK)
  end

  def draw_genre_option
    for i in 0..3
      Gosu.draw_rect(245 * i + 20, 60, 225, 40, @genre_bar_color[i], ZOrder::PLAYER)
    end
    @font.draw("#{GENRE_NAMES[0]}",95, 62,ZOrder::UI,1,1,Gosu::Color::BLACK)
    @font.draw("#{GENRE_NAMES[1]}",315, 62,ZOrder::UI,1,1,Gosu::Color::BLACK)
    @font.draw("#{GENRE_NAMES[2]}",585, 62,ZOrder::UI,1,1,Gosu::Color::BLACK)
    @font.draw("#{GENRE_NAMES[3]}",835, 62,ZOrder::UI,1,1,Gosu::Color::BLACK)
  end

  def draw_genre_track()
    @font.draw("Track list:",20,110,ZOrder::UI,1,1,Gosu::Color::BLACK)
    for k in 0..@albums_by_genre[@genre_index].tracks.length - 1
      @font.draw("#{k+1}. #{@albums_by_genre[@genre_index].tracks[k].name} ",40,150 + k * 50,ZOrder::UI,1,1,Gosu::Color::BLACK)
    end
  end

  def draw_favorite_option()
    for i in 0..1
      Gosu.draw_rect(487.5 * i + 25, 60, 462.5, 40, @favorite_bar_color[i], ZOrder::PLAYER)
    end
    @font.draw("Favorite tracks",150, 62,ZOrder::UI,1,1,Gosu::Color::BLACK)
    @font.draw("Add tracks",665, 62,ZOrder::UI,1,1,Gosu::Color::BLACK)
  end

  def draw_favorite_track()
    if @favorite_index == 1
      for k in 0..@album_add.tracks.length - 1
        @font.draw("#{k+1}. #{@album_add.tracks[k].name} ",40,125 + k * 50,ZOrder::UI,1,1,Gosu::Color::BLACK)
      end
    else
      for k in 0..@favorite.length - 1
        @font.draw("#{k+1}. #{@favorite[k].name} ",40,125 + k * 50,ZOrder::UI,1,1,Gosu::Color::BLACK)
      end
    end
  end

  def area_clicked(leftX, topY, rightX, bottomY)
    if mouse_x > leftX and mouse_x < rightX and mouse_y > topY and mouse_y < bottomY
      true
    else
      false
    end
  end

  # Takes a track index and an Album and plays the Track from the Album

  def playTrack(track_index, album)
  	@track = Gosu::Song.new(album.tracks[track_index].location)
  	@track.play(looping = true)
  end

  def playTrack_genre(track_index, album)
  	@track_genre = Gosu::Song.new(album.tracks[track_index].location)
  	@track_genre.play(looping = true)
  end

  def playTrack_favorite(track_index, tracks)
  	@track_favorite = Gosu::Song.new(tracks[track_index].location)
  	@track_favorite.play(looping = true)
  end

# Not used? Everything depends on mouse actions.

	def update
    #back button
    if area_clicked(280, 900, 355, 975)
      @back = Gosu::Image.new('images/back_hover.png')
    else
      @back = Gosu::Image.new('images/back.png')
    end
    #restart button
    if area_clicked(380, 900, 455, 975)
      @restart = Gosu::Image.new('images/restart_hover.png')
    else
      @restart = Gosu::Image.new('images/restart.png')
    end
    #play button
    if area_clicked(485, 900, 555, 975)
      @play = Gosu::Image.new('images/play_hover.png')
    else
      @play = Gosu::Image.new('images/play.png')
    end
    #pause button
    if area_clicked(585, 900, 655, 975)
      @pause = Gosu::Image.new('images/pause_hover.png')
    else
      @pause = Gosu::Image.new('images/pause.png')
    end
    #front button
    if area_clicked(685, 900, 755, 975)
      @front = Gosu::Image.new('images/front_hover.png')
    else
      @front = Gosu::Image.new('images/front.png')
    end
    @locs = [mouse_x, mouse_y]
    case @menu
    when :menu
      for i in 0..@album_chosen.tracks.length-1
        #track hover
        if area_clicked(20, 420 + 50 * i, 525, 450 + 50 * i)
          @track_hover_index = i
          @visible = true
          break
        else
          @visible = false
        end
      end
    when :genre
      for i in 0..@albums_by_genre[@genre_index].tracks.length-1
        if area_clicked(40, 150 + i * 50, 500, 180 + i * 50)
          @track_hover_index_genre = i
          @visible_genre = true
          break
        else
          @visible_genre = false
        end
      end
    when :favorite
      if @favorite_index == 0
        for i in 0..@favorite.length-1
          #track hover
          if area_clicked(40, 125 + i * 50, 500, 155 + i * 50)
            @track_hover_index_favorite = i
            @visible_favorite = true
            break
          else
            @visible_favorite = false
          end
        end
      else
        for i in 0..@album_add.tracks.length-1
          #track hover
          if area_clicked(40, 125 + i * 50, 500, 155 + i * 50)
            @track_hover_index_add = i
            @visible_add = true
            break
          else
            @visible_add = false
          end
        end
      end
    end
	end
 # Draws the album images and the track list for the selected album

 	def needs_cursor?; true; end

	def button_down(id)
    if id == Gosu::MsLeft
      for i in 0..2
        if area_clicked(325 * i + 25, 0, 325 * i + 325, 50)
          @menu_bar_color[@menu_index] = Gosu::Color::GRAY
          @menu_index = i
          @menu = @menu_option[@menu_index]
          @menu_bar_color[i] = Gosu::Color::AQUA
          if i == 0
            if @track
              @visible_cicle = true
            end
            @visible_cicle_genre = false
            @visible_cicle_favorite = false
          elsif i == 1
            initialize_genre()
            @visible_cicle = false
            @visible_cicle_favorite = false
            if @track_genre
              @visible_cicle_genre = true
            end
          elsif i == 2
            initialize_favorite()
            @visible_cicle = false
            @visible_cicle_genre = false
            if @track_favorite
              @visible_cicle_favorite = true
            end
          end
        end
      end
      case @menu
      when :menu
        @locs = [mouse_x, mouse_y]
        #album click
        for i in 0..@albums.length
    	   	if area_clicked(20 + i * WIDTH / @albums.length, 60, 220 + i * WIDTH / @albums.length, 260)
            album_chosen_index_previous = @album_chosen_index
            @album_chosen_index = i
            tmp = @album_border[album_chosen_index_previous]
            @album_border[album_chosen_index_previous] = @album_border[@album_chosen_index]
            @album_border[@album_chosen_index] = tmp
            @visible_cicle = false
            @track_hover_index = 0
            break
          end
        end
        #track click
        for i in 0..@album_chosen.tracks.length-1
          if area_clicked(20, 420 + 50 * i, 525, 450 + 50 * i)
            @visible_cicle = true
            @album_play = @albums[@album_chosen_index]
            @track_click_index = i
            @visible_cicle_genre = false
            @visible_cicle_favorite = false
            @track_genre = nil
            @album_play_genre = nil
            @track_favorite = nil
            playTrack(@track_click_index, @album_play)
            break
          end
        end
        if @track
          #back button
          if area_clicked(280, 900, 355, 975)
            previous_track()
          end
          #restart button
          if area_clicked(380, 900, 455, 975)
            playTrack(@track_click_index, @album_play)
          end
          #play button
          if area_clicked(485, 900, 555, 975)
            @track.play()
          end
          #pause button
          if area_clicked(585, 900, 655, 975)
            @track.pause()
          end
          #front button
          if area_clicked(685, 900, 755, 975)
            next_track()
          end
        end
        #sort button
        if area_clicked(600, 500, 755, 530)
          if @track_click_index != nil
            track_play = @album_play.tracks[@track_click_index].name
          end
          case @track_sort
          when :not_sorted
            for i in 0..@albums.length-1
              sort_track_array(@albums[i].tracks)
            end
            @track_sort = :sorted
          when :sorted
            for i in 0..@albums.length-1
              @albums[i].tracks.reverse!
            end
            @track_sort = :reverse_sorted
          when :reverse_sorted
            for i in 0..@albums.length-1
              @albums[i].tracks.reverse!
            end
            @track_sort = :sorted
          end
          if @track_click_index != nil
            for i in 0..@album_play.tracks.length-1
              if track_play == @album_play.tracks[i].name
                @track_click_index = i
                break
              end
            end
          end
        end
        #random button
        if area_clicked(225, 925, 255, 955)
          @visible_cicle = true
          if @album_play == @album_chosen
            track_click_index_previous = @track_click_index
            @track_click_index = rand(@album_chosen.tracks.length)
            while track_click_index_previous == @track_click_index
              @track_click_index = rand(@album_chosen.tracks.length)
            end
          else
            @track_click_index = rand(@album_chosen.tracks.length)
            @album_play = @album_chosen
          end
          playTrack(@track_click_index, @album_play)
        end
      when :genre
        for i in 0..3
          if area_clicked(245 * i + 20, 60, 245 * (i +1), 100)
            @genre_bar_color[@genre_index] = Gosu::Color::GRAY
            @genre_index = i
            @genre = @genre_option[@genre_index]
            @genre_bar_color[i] = Gosu::Color::AQUA
            @visible_cicle_genre = false
          end
        end
        @album_chosen = @albums[@album_chosen_index]
        #track click
        for i in 0..@albums_by_genre[@genre_index].tracks.length-1
          if area_clicked(40, 150 + i * 50, 500, 180 + i * 50)
            @visible_cicle_genre = true
            @visible_cicle = false
            @visible_cicle_favorite = false
            @album_play_genre = @albums_by_genre[@genre_index]
            @track_click_index_genre = i
            @track = nil
            @album_play = nil
            @track_favorite = nil
            playTrack_genre(@track_click_index_genre, @album_play_genre)
            break
          end
        end
        if @track_genre
          #back button
          if area_clicked(280, 900, 355, 975)
            previous_track_genre()
          end
          #restart button
          if area_clicked(380, 900, 455, 975)
            playTrack_genre(@track_click_index_genre, @album_play_genre)
          end
          #play button
          if area_clicked(485, 900, 555, 975)
            @track_genre.play()
          end
          #pause button
          if area_clicked(585, 900, 655, 975)
            @track_genre.pause()
          end
          #front button
          if area_clicked(685, 900, 755, 975)
            next_track_genre()
          end
        end
        #random button
        if area_clicked(225, 925, 255, 955)
          @visible_cicle_genre = true
          if @album_play_genre == @albums_by_genre[@genre_index]
            track_click_index_previous = @track_click_index_genre
            @track_click_index_genre = rand(@albums_by_genre[@genre_index].tracks.length)
            while track_click_index_previous == @track_click_index_genre
              @track_click_index_genre = rand(@albums_by_genre[@genre_index].tracks.length)
            end
          else
            @track_click_index_genre = rand(@albums_by_genre[@genre_index].tracks.length)
            @album_play_genre = @albums_by_genre[@genre_index]
          end
          playTrack_genre(@track_click_index_genre, @album_play_genre)
        end
        if area_clicked(600, 500, 755, 530)
          if @track_click_index_genre != nil
            track_play = @album_play_genre.tracks[@track_click_index_genre].name
          end
          case @track_sort_genre
          when :not_sorted
            for i in 0..@albums_by_genre.length-1
              sort_track_array(@albums_by_genre[i].tracks)
            end
            @track_sort_genre = :sorted
          when :sorted
            for i in 0..@albums_by_genre.length-1
              @albums_by_genre[i].tracks.reverse!
            end
            @track_sort_genre = :reverse_sorted
          when :reverse_sorted
            for i in 0..@albums_by_genre.length-1
              @albums_by_genre[i].tracks.reverse!
            end
            @track_sort_genre = :sorted
          end
          if @track_click_index_genre != nil
            for i in 0..@album_play_genre.tracks.length-1
              if track_play == @album_play_genre.tracks[i].name
                @track_click_index_genre = i
                break
              end
            end
          end
        end
      when :favorite
        for i in 0..1
          if area_clicked(487.5 * i + 25, 60, 487.5 * (i +1), 100)
            @favorite_bar_color[@favorite_index] = Gosu::Color::GRAY
            @favorite_index = i
            @favorite_bar_color[i] = Gosu::Color::AQUA
          end
        end
        if @favorite_index == 1
          @visible_cicle_favorite = false
          for i in 0..@album_add.tracks.length-1
            if area_clicked(40, 125 + i * 50, 500, 155 + i * 50)
              @track_add = @album_add.tracks.delete_at(i)
              @album_favorite.tracks << @track_add
              break
            end
          end
          if area_clicked(600, 500, 755, 530)
            case @track_sort_add
            when :not_sorted
              sort_track_array(@album_add.tracks)
              @track_sort_add = :sorted
            when :sorted
              @album_add.tracks.reverse!
              @track_sort_add = :reverse_sorted
            when :reverse_sorted
              @album_add.tracks.reverse!
              @track_sort_add = :sorted
            end
          end
        elsif @favorite_index == 0
          if @favorite.length > 0
            for i in 0..@favorite.length-1
              if area_clicked(40, 125 + i * 50, 500, 155 + i * 50)
                @track_click_index_favorite = i
                playTrack_favorite(@track_click_index_favorite, @favorite)
                @visible_cicle_favorite = true
                @visible_cicle = false
                @visible_cicle_genre = false
                @track_genre = nil
                @track = nil
                @album_play = nil
                @album_play_genre = nil
              end
            end
          end
          if area_clicked(600, 500, 755, 530)
            if @track_click_index_favorite != nil
              track_play = @favorite[@track_click_index_favorite].name
            end
            case @track_sort_favorite
            when :not_sorted
              sort_track_array(@favorite)
              @track_sort_favorite = :sorted
            when :sorted
              @favorite.reverse!
              @track_sort_favorite = :reverse_sorted
            when :reverse_sorted
              @favorite.reverse!
              @track_sort_favorite = :sorted
            end
            if @track_click_index_favorite != nil
              for i in 0..@favorite.length-1
                if track_play == @favorite[i].name
                  @track_click_index_favorite = i
                  break
                end
              end
            end
          end
          if @track_favorite
            #back button
            if area_clicked(280, 900, 355, 975)
              previous_track_favorite()
            end
            #restart button
            if area_clicked(380, 900, 455, 975)
              playTrack_favorite(@track_click_index_favorite, @favorite)
            end
            #play button
            if area_clicked(485, 900, 555, 975)
              @track_favorite.play()
            end
            #pause button
            if area_clicked(585, 900, 655, 975)
              @track_favorite.pause()
            end
            #front button
            if area_clicked(685, 900, 755, 975)
              next_track_favorite()
            end
          end
          #random button
          if area_clicked(225, 925, 255, 955)
            @visible_cicle_favorite = true
              track_click_index_previous = @track_click_index_favorite
              @track_click_index_favorite = rand(@favorite.length)
              while track_click_index_previous == @track_click_index_favorite
                @track_click_index_favorite = rand(@favorite.length)
              end
            playTrack_favorite(@track_click_index_favorite, @favorite)
          end
        end
      end
    elsif id == Gosu::KbLeft
      case @menu
      when :menu
        if @track
          previous_track()
        end
      when :genre
        if @track_genre
          previous_track_genre()
        end
      when :favorite
        if @track_favorite
          previous_track_favorite()
        end
      end
    elsif id == Gosu::KbRight
      case @menu
      when :menu
        if @track
          next_track()
        end
      when :genre
        if @track_genre
          next_track_genre()
        end
      when :favorite
        if @track_favorite
          next_track_favorite()
        end
      end
    end
	end

  #selection sort
  def sort_track_array(array_sort)
    n = array_sort.length
    for i in 0..n-2
      min = i
      for j in i+1..n-1
        if array_sort[j].name < array_sort[min].name
          min = j
        end
      end
      if min != i
        tmp = array_sort[i]
        array_sort[i] = array_sort[min]
        array_sort[min] = tmp
      end
    end
  end

  def previous_track()
    if @track_click_index > 0
      @track_click_index -= 1
      playTrack(@track_click_index, @album_play)
    else
      @track_click_index = @album_play.tracks.length-1
      playTrack(@track_click_index, @album_play)
    end
  end

  def next_track()
    if @track_click_index < @album_play.tracks.length-1
      @track_click_index += 1
      playTrack(@track_click_index, @album_play)
    else
      @track_click_index = 0
      playTrack(@track_click_index, @album_play)
    end
  end

  def previous_track_genre()
    if @track_click_index_genre > 0
      @track_click_index_genre -= 1
      playTrack_genre(@track_click_index_genre, @album_play_genre)
    else
      @track_click_index_genre = @album_play_genre.tracks.length-1
      playTrack_genre(@track_click_index_genre, @album_play_genre)
    end
  end

  def next_track_genre()
    if @track_click_index_genre < @album_play_genre.tracks.length-1
      @track_click_index_genre += 1
      playTrack_genre(@track_click_index_genre, @album_play_genre)
    else
      @track_click_index_genre = 0
      playTrack_genre(@track_click_index_genre, @album_play_genre)
    end
  end

  def previous_track_favorite()
    if @track_click_index_favorite > 0
      @track_click_index_favorite -= 1
      playTrack_favorite(@track_click_index_favorite, @favorite)
    else
      @track_click_index_favorite = @favorite.length-1
      playTrack_favorite(@track_click_index_favorite, @favorite)
    end
  end

  def next_track_favorite()
    if @track_click_index_favorite < @favorite.length-1
      @track_click_index_favorite += 1
      playTrack_favorite(@track_click_index_favorite, @favorite)
    else
      @track_click_index_favorite = 0
      playTrack_favorite(@track_click_index_favorite, @favorite)
    end
  end
end

# Show is a method that loops through update and draw

MusicPlayerMain.new.show # if __FILE__ == $0
