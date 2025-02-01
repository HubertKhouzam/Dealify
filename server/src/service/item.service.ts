import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Item, rowItem } from '../database/items.entity';
import * as fs from 'fs';
import * as csv from 'csv-parser';

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

  async processCsv(filePath: string): Promise<void> {
    const items: Item[] = [];

    return new Promise((resolve, reject) => {
      try {
        const stream = fs.createReadStream(filePath).pipe(csv());

        stream.on('data', (row) => {
          const item = this.createItemFromRow(row);
          if (item) {
            items.push(item);
          }
        });

        stream.on('end', () => {
          console.log('Total Items to Insert:', items.length);
          if (items.length > 0) {
            this.itemRepository
              .save(items)
              .then(() => {
                fs.unlinkSync(filePath);
                resolve();
              })
              .catch((error: Error) => reject(error));
          } else {
            fs.unlinkSync(filePath);
            resolve();
          }
        });

        stream.on('error', (error) => reject(error));
      } catch (error) {
        reject(new Error(`Failed to process file: ${String(error)}`));
      }
    });
  }

  private createItemFromRow(row: rowItem): Item | null {
    if (!row.name || !row.brand || !row.nominal || !row.store) {
      return null;
    }

    return this.itemRepository.create({
      name: row.name,
      brand: row.brand,
      price: parseFloat(row.nominal),
      store: row.store,
    });
  }
}
