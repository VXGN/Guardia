import { Router } from "express";
import multer from "multer";
import { UploadController } from "../controllers/upload.controller";
import { authMiddleware } from "../middlewares/auth.middleware";

const router = Router();
const controller = new UploadController();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
});

router.use(authMiddleware);

router.post("/single", upload.single("file"), controller.uploadSingle);
router.post("/multiple", upload.array("files", 5), controller.uploadMultiple);

export { router as uploadRoutes };
