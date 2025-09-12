class WelcomeController < ApplicationController
  def hello
    render text: "Hello World"
  end

  def notfound
    render 'notfound', status: 404
  end
end
