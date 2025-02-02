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
  findItem(name: string): Promise<Item[] | null> {
    return this.itemRepository
      .createQueryBuilder('item')
      .where('item.name ILIKE :searchTerm', { searchTerm: `%${name}%` })
      .getMany();
  }

  async findItemsByFuzzyMatch(searchTerm: string): Promise<Item[]> {
    return this.itemRepository
      .createQueryBuilder('item')
      .where(`similarity(item.name, :searchTerm) > 0.2`, { searchTerm })
      .orderBy(`similarity(item.name, :searchTerm)`, 'DESC')
      .getMany();
  }

  async processCsv(filePath: string): Promise<void> {
    const batchSize = 1000;
    let items: Item[] = [];
    let currentBatch: Item[] = [];

    return new Promise((resolve, reject) => {
      const stream = fs
        .createReadStream(filePath)
        .pipe(csv())
        .on('data', (row) => {
          const item = this.createItemFromRow(row);
          if (item) {
            currentBatch.push(item);
            if (currentBatch.length >= batchSize) {
              items.push(...currentBatch);
              currentBatch = [];
            }
          }
        })
        .on('end', () => {
          if (currentBatch.length > 0) {
            items.push(...currentBatch);
          }

          // Process all batches after stream is complete
          this.processAllBatches(items, batchSize)
            .then(() => {
              fs.unlinkSync(filePath);
              resolve();
            })
            .catch((error: Error) => {
              reject(error);
            });
        })
        .on('error', (error) => {
          reject(new Error(`Failed to process file: ${String(error)}`));
        });
    });
  }

  private async processAllBatches(
    items: Item[],
    batchSize: number,
  ): Promise<void> {
    for (let i = 0; i < items.length; i += batchSize) {
      const batch = items.slice(i, i + batchSize);
      await this.saveBatch(batch);
      console.log(
        `Processed batch ${i / batchSize + 1}: ${batch.length} items`,
      );
    }
  }

  private async saveBatch(items: Item[]): Promise<void> {
    try {
      await this.itemRepository
        .createQueryBuilder()
        .insert()
        .into(Item)
        .values(items)
        .execute();
    } catch (error) {
      throw new Error(`Failed to save batch: ${String(error)}`);
    }
  }

  private createItemFromRow(row: rowItem): Item | null {
    if (!row.name || !row.nominal || !row.store) {
      return null;
    }

    return this.itemRepository.create({
      name: row.name,
      price: parseFloat(row.nominal),
      store: row.store,
    });
  }
}
