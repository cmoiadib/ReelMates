// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import LoadingController from "./loading_controller"
import ResultsController from "./results_controller"

application.register("loading", LoadingController)
application.register("results", ResultsController)
