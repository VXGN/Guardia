import { Router } from "express";
import { ReportController } from "../controllers/report.controller";
import { authMiddleware } from "../middlewares/auth.middleware";
import { validate } from "../middlewares/validate.middleware";
import {
  createReportSchema,
  listReportsSchema,
  updateReportStatusSchema,
  getReportSchema,
} from "../validators/report.validator";

const router = Router();
const controller = new ReportController();

router.use(authMiddleware);

// Public user endpoints
router.post("/", validate(createReportSchema), controller.create);
router.get("/", validate(listReportsSchema), controller.list);
router.get("/my", validate(listReportsSchema), controller.getMyReports);
router.get("/stats", controller.getStats); // Admin only (checked in controller)
router.get("/:id", validate(getReportSchema), controller.getById);
router.patch("/:id/status", validate(updateReportStatusSchema), controller.updateStatus);

export { router as reportRoutes };
