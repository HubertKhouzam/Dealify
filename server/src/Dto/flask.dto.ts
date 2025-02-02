export interface FlaskResponseImage {
  message: string;
  path?: string;
  error?: string;
}

interface SearchResult {
  rank: number;
  text: string;
}

export type SearchResponse = SearchResult[];
