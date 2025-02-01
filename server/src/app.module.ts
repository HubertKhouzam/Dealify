import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Item } from './database/items.entity';
import { ConfigModule } from '@nestjs/config';

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
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
