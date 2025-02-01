import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Item } from '../database/items.entity';
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

  private createItemFromRow(row: Item): Item | null {
    if (!row.name || !row.brand || !row.price || !row.store) {
      return null;
    }

    return this.itemRepository.create({
      name: row.name,
      brand: row.brand,
      price: row.price,
      store: row.store,
    });
  }

  private async saveItemsToDatabase(items: Item[]): Promise<void> {
    if (items.length > 0) {
      await this.itemRepository.save(items);
    }
  }

  private deleteFile(filePath: string): void {
    fs.unlinkSync(filePath);
  }
}
