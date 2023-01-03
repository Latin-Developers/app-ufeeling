# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require 'gchart'

module UFeeling
  # Web App
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :caching
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets', css: 'style.css'
    plugin :common_logger, $stderr

    use Rack::MethodOverride

    route do |routing|
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'
      routing.public
      # [GET]   /                             Home
      # [POST]  /videos?url=                  Analyze a new video
      # [GET]   /videos/:video_id             Gets the analysis of a video
      # [GET]   /videos/:video_id/comments    Gets the analysis of a video including the list of top comments

      # [GET] /
      routing.root do
        # Get cookie viewer's previously seen videos
        session[:watching] ||= []
        category_selected = routing.params['category']
        result = Services::HomePage.new.call(video_ids: session[:watching], category_selected:)

        if result.failure?
          flash[:error] = result.failure
          videos = []
        else
          videos = result.value![:videos].videos
          categories = result.value![:categories].categories
          videos_by_category = result.value![:videos_by_category].videos
          # flash.now[:notice] = 'Add a Youtube video to get started' if videos.none?

          session[:watching] = videos.map(&:origin_id)
        end

        home_info = Views::HomeInfo.new(videos, categories, videos_by_category, category_selected)

        view 'home', locals: { info: home_info }
      end

      # [...] /videos/
      routing.on 'videos' do
        routing.is do
          # [POST]  /videos?url=
          routing.post do
            url_request = Forms::NewVideo.new.call(routing.params)
            new_video = Services::AddVideo.new.call(url_request)

            if new_video.failure?
              flash[:error] = new_video.failure
              routing.redirect '/'
            end

            video = new_video.value!
            session[:watching].insert(0, video.origin_id).uniq!
            flash[:notice] = 'Video under analysis'
            routing.redirect "videos/#{video.origin_id}"
          end
        end

        # [...]  /videos/:video_origin_id
        routing.on String do |video_origin_id|
          # [GET]  /videos/:video_origin_id
          routing.is do
            routing.get do
              # Get Video from API
              video_result = Services::GetVideo.new.call(
                watched_list: session[:watching] || [],
                video_id: video_origin_id
              )

              if video_result.failure?
                flash[:error] = video_result.failure
                routing.redirect '/'
              end

              analize = OpenStruct.new(video_result.value!) # rubocop:disable Style/OpenStructUse

              if analize.processing?
                flash.now[:notice] = 'The video is under analisis'
              else
                video_info = Views::VideoInfo.new(video_result.value![:video], video_result.value![:comments]&.comments)

                # Only use browser caching in production
                App.configure :production do
                  response.expires 60, public: true
                end
              end

              bar_chart = Gchart.line(
                title: 'Title for GChart',
                bg: '000',
                legend: ['first data set label'],
                data: [10, 30, 120, 45, 72],
                axis_labels: [%w[J F M A M]],
                axis_with_labels: %w[x y],
                axis_range: [nil, [2, 17, 5]]
              )

              processing = Views::VideoProcessing.new(
                App.config, analize.processing, video_origin_id
              )

              # Show viewer the video
              view 'video', locals: { video_info:, processing:, bar_chart: }
            end
          end

          # [...]  /videos/:video_origin_id/comments
          routing.on 'comments' do
            # [GET]  /videos/:video_origin_id/comments
            # routing.get {}
          end
        end
      end
    end
  end
end
