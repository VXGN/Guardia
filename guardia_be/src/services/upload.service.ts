import { firebaseStorage } from "../config/firebase";
import { v4 as uuidv4 } from "uuid";
import { BadRequestError } from "../utils/errors";

export class UploadService {
  async uploadFile(file: Express.Multer.File, folder: string = "uploads"): Promise<string> {
    if (!file) {
      throw new BadRequestError("No file provided");
    }

    const bucket = firebaseStorage.bucket();
    const fileName = `${folder}/${uuidv4()}_${file.originalname.replace(/\s+/g, "_")}`;
    const fileUpload = bucket.file(fileName);

    const blobStream = fileUpload.createWriteStream({
      metadata: {
        contentType: file.mimetype,
      },
    });

    return new Promise((resolve, reject) => {
      blobStream.on("error", (error) => {
        reject(error);
      });

      blobStream.on("finish", async () => {
        // The file upload is complete
        // Make the file public if needed, or get a signed URL
        // For simplicity in this competition, we'll use a public-style URL if the bucket is public,
        // or a standard Firebase storage URL format.
        // https://firebasestorage.googleapis.com/v0/b/[BUCKET_NAME]/o/[FILE_PATH]?alt=media
        
        const publicUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(fileName)}?alt=media`;
        resolve(publicUrl);
      });

      blobStream.end(file.buffer);
    });
  }

  async uploadMultiple(files: Express.Multer.File[], folder: string = "uploads"): Promise<string[]> {
    const uploadPromises = files.map((file) => this.uploadFile(file, folder));
    return Promise.all(uploadPromises);
  }
}
