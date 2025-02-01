import { Module } from '@nestjs/common';
import { ItemsController } from './controller/item.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Item } from './database/items.entity';
import { ConfigModule } from '@nestjs/config';
import { ItemsService } from './service/item.service';
import { FileUploadService } from './service/file.service';

@Module({
  imports: [
    ConfigModule.forRoot(),
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.DATABASE_URL,
      entities: [Item],
      synchronize: true,
      ssl: {
        rejectUnauthorized: false, // Required for Render connections
      },
    }),
    TypeOrmModule.forFeature([Item]),
  ],
  controllers: [ItemsController],
  providers: [ItemsService, FileUploadService],
})
export class AppModule {}
