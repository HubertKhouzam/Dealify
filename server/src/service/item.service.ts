import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Item } from '../database/items.entity';

@Injectable()
export class ItemsService {
  constructor(
    @InjectRepository(Item)
    private readonly itemRepository: Repository<Item>,
  ) {}

  findAll(): Promise<Item[]> {
    return this.itemRepository.find();
  }
  findOne(name: string): Promise<Item | null> {
    return this.itemRepository.findOne({ where: { name } });
  }
}
