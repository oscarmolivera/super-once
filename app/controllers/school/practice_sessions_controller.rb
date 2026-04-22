module School
  class PracticeSessionsController < School::BaseController
    before_action :set_practice_session, only: %i[show edit update destroy attendance]

    def index
      @practice_sessions = policy_scope(PracticeSession).includes(:category).order(starts_at: :desc).limit(200)
    end

    def show
      authorize @practice_session
      @attendance_records = policy_scope(AttendanceRecord)
        .where(practice_session: @practice_session)
        .joins(:player)
        .includes(:player)
        .order("players.last_name ASC, players.first_name ASC")
    end

    def new
      @practice_session = PracticeSession.new(academy: current_academy)
      authorize @practice_session
    end

    def create
      @practice_session = PracticeSession.new(practice_session_params.merge(academy: current_academy))
      authorize @practice_session

      if @practice_session.save
        redirect_to school_practice_session_path(@practice_session), notice: "Session scheduled."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @practice_session
    end

    def update
      authorize @practice_session
      if @practice_session.update(practice_session_params)
        redirect_to school_practice_session_path(@practice_session), notice: "Session updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @practice_session
      @practice_session.destroy
      redirect_to school_practice_sessions_path, notice: "Session deleted."
    end

    # GET/PATCH /school/practice_sessions/:id/attendance
    def attendance
      authorize @practice_session, :attendance?

      @category = @practice_session.category
      @players = @category.players.order(:last_name, :first_name)

      if request.patch?
        AttendanceRecord.transaction do
          @players.each do |player|
            status = params.dig(:attendance, player.id.to_s, :status).presence
            notes  = params.dig(:attendance, player.id.to_s, :notes).to_s.presence
            next unless status

            record = AttendanceRecord.find_or_initialize_by(
              academy: current_academy,
              practice_session: @practice_session,
              player: player
            )
            record.status = status
            record.notes  = notes
            authorize record, :upsert?
            record.save!
          end
        end

        redirect_to attendance_school_practice_session_path(@practice_session), notice: "Attendance saved."
      else
        @attendance_by_player_id = policy_scope(AttendanceRecord)
          .where(practice_session: @practice_session, player: @players)
          .index_by(&:player_id)
      end
    end

    private

    def set_practice_session
      @practice_session = policy_scope(PracticeSession).find(params[:id])
    end

    def practice_session_params
      params.require(:practice_session).permit(:category_id, :starts_at, :ends_at, :location, :notes)
    end
  end
end

