import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class Item {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 200 })
  name: string;

  @Column('numeric')
  price: number;

  @Column()
  store: string;
}

export interface rowItem {
  name: string;
  nominal: string;
  store: string;
}
