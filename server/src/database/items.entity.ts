import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class Item {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 20 })
  name: string;

  @Column()
  brand: string;

  @Column()
  price: number;

  @Column()
  store: string;
}

export interface rowItem {
  name: string;
  brand: string;
  nominal: string;
  store: string;
}
