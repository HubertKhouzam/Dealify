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
import { SearchResponse } from 'src/Dto/flask.dto';
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
  async getItemsBySearch(
    @Param('search') search: string,
  ): Promise<SearchResponse> {
    const flaskApiUrl = `${process.env.FLASK_API_URL}/search/${encodeURIComponent(search)}`;

    if (!process.env.FLASK_API_URL) {
      throw new Error('FLASK_API_URL is not defined in .env');
    }

    try {
      const { data } = await axios.get<SearchResponse>(flaskApiUrl);
      return data;
    } catch (error) {
      console.error('Error fetching from Flask API:', error);
      throw new Error('Failed to fetch search results');
    }
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

    const flaskApiUrl = `${process.env.FLASK_API_URL}/upload`;
    if (!flaskApiUrl) {
      throw new Error('FLASK_API_URL is not defined in .env');
    }

    try {
      const response = await axios.post(flaskApiUrl, formData, {
        headers: { ...formData.getHeaders() },
      });

      await fs.promises.unlink(imagePath);
      return response.data;
    } catch (error: any) {
      console.error(
        'Error uploading to Flask:',
        // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
        error.response?.data || error.message,
      );

      await fs.promises
        .unlink(imagePath)
        .catch((err) => console.error('Error deleting image file:', err));

      return { error: 'Failed to upload image to Flask API' };
    }
  }
}
