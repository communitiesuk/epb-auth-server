# frozen_string_literal: true

describe "Acceptance::Errors", type: :feature do
  let(:logger) { instance_double(Logger) }
  let(:show_exceptions) { false }
  let(:exception) { "boom" }

  let(:app) do
    test_logger = logger
    test_exception = exception

    Class.new(Service) do
      set :logger, test_logger
      set :raise_errors, false
      set :show_exceptions, false

      get "/test-error" do
        raise test_exception
      end
    end
  end

  before do
    allow(logger).to receive(:error)
  end

  context "with an uncaught error" do
    before do
      get "/test-error"
    end

    it "responds with a 500 status" do
      expect(last_response.status).to eq 500
    end

    it "does not display a verbose error message" do
      expect(last_response.body).to eq "SERVER ERROR"
    end

    it "logs the error to the log file" do
      expect(logger).to have_received(:error).with(
        satisfy do |error|
          expect(JSON.parse(error)).to eq("type" => "RuntimeError", "message" => "boom", "backtrace" => [])
        end,
      )
    end
  end

  context "with a Boundary::ValidationError" do
    let(:exception) { Boundary::ValidationError.new({ "foo" => "bar" }) }

    before do
      get "/test-error"
    end

    it "responds with a 500 status" do
      expect(last_response.status).to eq 422
    end

    it "does not display a verbose error message" do
      expect(JSON.parse(last_response.body)).to eq("code" => "VALIDATION_ERROR", "errors" => { "foo" => "bar" })
    end

    it "does not log the error to the log file" do
      expect(logger).not_to have_received(:error)
    end
  end

  context "with a Boundary::NotAuthenticatedError" do
    let(:exception) { Boundary::NotAuthenticatedError }

    before do
      get "/test-error"
    end

    it "responds with a 500 status" do
      expect(last_response.status).to eq 401
    end

    it "does not display a verbose error message" do
      expect(JSON.parse(last_response.body)).to eq("code" => "NOT_AUTHENTICATED")
    end

    it "does not log the error to the log file" do
      expect(logger).not_to have_received(:error)
    end
  end

  context "with a Boundary::NotAuthorizedError" do
    let(:exception) { Boundary::NotAuthorizedError }

    before do
      get "/test-error"
    end

    it "responds with a 500 status" do
      expect(last_response.status).to eq 403
    end

    it "does not display a verbose error message" do
      expect(JSON.parse(last_response.body)).to eq("code" => "NOT_AUTHORIZED")
    end

    it "does not log the error to the log file" do
      expect(logger).not_to have_received(:error)
    end
  end

  context "with an uncaught error in a development environment" do
    before do
      app.set :host_authorization, { permitted_hosts: %w[] }
      app.set :environment, :development

      get "/test-error"
    end

    it "responds with a 500 status" do
      expect(last_response.status).to eq 500
    end

    it "displays the message" do
      expect(last_response.body).to include "boom"
    end

    it "logs the error to the log file" do
      expect(logger).to have_received(:error).with(
        satisfy do |error|
          expect(JSON.parse(error)).to eq("type" => "RuntimeError", "message" => "boom", "backtrace" => [])
        end,
      )
    end
  end
end
