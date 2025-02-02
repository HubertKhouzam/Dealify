import { Injectable } from '@nestjs/common';
import { diskStorage } from 'multer';
import { extname } from 'path';

@Injectable()
export class FileUploadService {
  getStorageOptions(destinationPath: string) {
    return {
      storage: diskStorage({
        destination: destinationPath,
        filename: (_, file, callback) => {
          const uniqueSuffix =
            Date.now() + '-' + Math.round(Math.random() * 1e9);
          const newFileName =
            file.fieldname + '-' + uniqueSuffix + extname(file.originalname);
          callback(null, newFileName);
        },
      }),
      fileFilter: (
        req: Request,
        file: Express.Multer.File,
        callback: (error: Error | null, acceptFile: boolean) => void,
      ) => {
        if (
          !file.originalname.match(/\.(csv)$/) &&
          !file.originalname.match(/\.(jpg)$/) &&
          !file.originalname.match(/\.(webp)$/) &&
          !file.originalname.match(/\.(jpeg)$/)
        ) {
          return callback(new Error('File type invalid'), false);
        }
        callback(null, true);
      },
    };
  }
}
