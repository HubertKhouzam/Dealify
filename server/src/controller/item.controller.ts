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

@Controller('items')
export class ItemsController {
  constructor(private readonly itemsService: ItemsService) {}

  @Get('/')
  getAllItems() {
    return this.itemsService.findAll();
  }

  @Get('/:name')
  getItemByName(@Param('name') name: string) {
    return this.itemsService.findOne(name);
  }

  @Get('/search/:search')
  getItemsBySearch(@Param('search') search: string) {
    return this.itemsService.findItemsByFuzzyMatch(search);
  }

  @Post('/upload')
  @UseInterceptors(
    FileInterceptor('file', new FileUploadService().getStorageOptions()),
  )
  async uploadFile(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      return { message: 'No file uploaded' };
    }

    await this.itemsService.processCsv(file.path);
    console.log('CSV file processed successfully');
    return { message: 'CSV file processed successfully' };
  }
}
