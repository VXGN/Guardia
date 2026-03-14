import { Router } from "express";
import { AdminController } from "../controllers/admin.controller";
import { authMiddleware } from "../middlewares/auth.middleware";
import { validate } from "../middlewares/validate.middleware";
import {
  updateReportStatusSchema,
  listReportsSchema,
} from "../validators/admin.validator";

const router = Router();
const controller = new AdminController();

router.use(authMiddleware);

router.get("/dashboard", controller.getDashboardStats);
router.get("/reports", validate(listReportsSchema), controller.listReports);
router.get("/reports/:id", controller.getReport);
router.patch("/reports/:id/status", validate(updateReportStatusSchema), controller.updateReportStatus);

export { router as adminRoutes };
