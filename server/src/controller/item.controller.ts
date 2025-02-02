import {
  Controller,
  Get,
  Post,
  Param,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { ItemsService } from '../service/item.service';
import { FileUploadService } from 'src/service/file.service';
import { FileInterceptor } from '@nestjs/platform-express';
import axios from 'axios';
import * as FormData from 'form-data';
import { FlaskResponse } from 'src/Dto/flask.dto';
import * as fs from 'fs';

@Controller('items')
export class ItemsController {
  constructor(private readonly itemsService: ItemsService) {}

  @Get('/')
  getAllItems() {
    return this.itemsService.findAll();
  }

  @Get('/:name')
  getItemByName(@Param('name') name: string) {
    return this.itemsService.findItem(name);
  }

  @Get('/search/:search')
  getItemsBySearch(@Param('search') search: string) {
    return this.itemsService.findItemsByFuzzyMatch(search);
  }

  @Post('/upload')
  @UseInterceptors(
    FileInterceptor(
      'file',
      new FileUploadService().getStorageOptions('./uploads'),
    ),
  )
  async uploadFile(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      return { message: 'No file uploaded' };
    }

    await this.itemsService.processCsv(file.path);
    console.log('CSV file processed successfully');
    return { message: 'CSV file processed successfully' };
  }

  @Post('image')
  @UseInterceptors(
    FileInterceptor(
      'image',
      new FileUploadService().getStorageOptions('./src/controller/uploads/'),
    ),
  )
  async uploadImage(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      return { message: 'No image uploaded' };
    }
    const imagePath = `./src/controller/uploads/${file.filename}`;

    const formData = new FormData();
    formData.append('image', fs.createReadStream(imagePath), file.filename);

    const flaskApiUrl = process.env.FLASK_API_URL;
    if (!flaskApiUrl) {
      throw new Error('FLASK_API_URL is not defined in .env');
    }

    try {
      const response: FlaskResponse = await axios.post(flaskApiUrl, formData, {
        headers: { ...formData.getHeaders() },
      });
      return this.itemsService.findItem(response.message);
    } catch (error: any) {
      console.error(
        'Error uploading to Flask:',
        // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
        error.response?.data || error.message,
      );
      return { error: 'Failed to upload image to Flask API' };
    }
  }
}
