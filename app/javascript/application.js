// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "./controllers/loading_controller"
import "./controllers/application"
import "./controllers/results_controller"
import "@popperjs/core"
import "bootstrap"
import "@rails/actioncable"
import "channels"

import { createConsumer } from "@rails/actioncable"

export default createConsumer()
