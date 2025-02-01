import { Controller, Get, Post, Body, Param } from '@nestjs/common';
import { ItemsService } from '../service/item.service';

@Controller('items')
export class UsersController {
  constructor(private readonly itemsService: ItemsService) {}

  @Get('/')
  getAllItems() {
    return this.itemsService.findAll();
  }

  @Get('/:name')
  getItemByName(@Param('name') name: string) {
    return this.itemsService.findOne(name);
  }

  //   @Post('/items')
  //   addItemsByCSV(@Body csv_file : ) {
  //     return null
  //   }
}
