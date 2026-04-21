// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import SidebarController from "./sidebar_controller"
application.register("sidebar", SidebarController)