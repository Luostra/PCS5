const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

let notes = [
  {
    id: 1,
    title: 'Первая заметка',
    body: 'Это содержимое первой заметки для демонстрации работы API'
  },
  {
    id: 2,
    title: 'Вторая заметка',
    body: 'Это вторая тестовая заметка с некоторым содержанием'
  },
  {
    id: 3,
    title: 'Третья заметка',
    body: 'Это третья заметка'
  },
  {
    id: 4,
    title: 'Список покупок',
    body: 'Молоко, хлеб, яйца, фрукты, овощи'
  },
  {
    id: 5,
    title: 'План на неделю',
    body: 'Понедельник: встреча, вторник: тренировка, среда: учеба'
  },
  {
    id: 6,
    title: 'Идеи для проекта',
    body: 'Разработать мобильное приложение для заметок с синхронизацией'
  },
  {
    id: 7,
    title: 'Книги для прочтения',
    body: '«Чистый код», «Совершенный код», «Архитектура компьютера»'
  },
  {
    id: 8,
    title: 'Изучение английского',
    body: 'Новые слова: London, capital, great, Britain'
  },
  {
    id: 9,
    title: 'Фильмы к просмотру',
    body: 'Зелёная миля, Начало, Побег из Шоушенка'
  },
  {
    id: 10,
    title: 'Рецепт пасты',
    body: 'Спагетти, томатный соус, базилик, чеснок, пармезан'
  },
  {
    id: 11,
    title: 'Цели на год',
    body: 'Выучить новый язык программирования, прочитать 12 книг, путешествовать'
  },
  {
    id: 12,
    title: 'Пароли',
    body: 'Рабочий email: qwerty123, Соцсети: top_secret456'
  },
  {
    id: 13,
    title: 'Расписание дня',
    body: '9:00 - завтрак, 10:00 - работа, 13:00 - обед, 18:00 - отдых'
  },
  {
    id: 14,
    title: 'Подарки на праздники',
    body: 'Маме - цветы, папе - книга, другу - настольная игра'
  },
];

const findNoteById = (id) => {
  const noteId = parseInt(id);
  return notes.find(note => note.id === noteId);
};

const getNextId = () => {
  return Math.max(...notes.map(note => note.id), 0) + 1;
};


app.get('/posts', (req, res) => {
  const page = parseInt(req.query._page) || 1;
  const limit = parseInt(req.query._limit) || 20;
  
  const startIndex = (page - 1) * limit;
  const endIndex = startIndex + limit;
  
  const paginatedNotes = notes.slice(startIndex, endIndex);
  
  
  res.set({
    'X-Total-Count': notes.length,
    'X-Page': page,
    'X-Limit': limit,
    'X-Total-Pages': Math.ceil(notes.length / limit)
  });
  
  res.json(paginatedNotes);
});

app.get('/posts/:id', (req, res) => {
  const note = findNoteById(req.params.id);
  
  if (!note) {
    return res.status(404).json({
      error: 'Note not found',
      message: `Note with id ${req.params.id} does not exist`
    });
  }
  
  res.json(note);
});

app.post('/posts', (req, res) => {
  const { title, body } = req.body;
  
  if (!title || !body) {
    return res.status(400).json({
      error: 'Validation failed',
      message: 'Title and body are required'
    });
  }
  
  const newNote = {
    id: getNextId(),
    title: title.trim(),
    body: body.trim(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };
  
  notes.push(newNote);
  
  res.status(201).json(newNote);
});

app.patch('/posts/:id', (req, res) => {
  const note = findNoteById(req.params.id);
  
  if (!note) {
    return res.status(404).json({
      error: 'Note not found',
      message: `Note with id ${req.params.id} does not exist`
    });
  }
  
  const { title, body } = req.body;
  
  if (title !== undefined) {
    note.title = title.trim();
  }
  
  if (body !== undefined) {
    note.body = body.trim();
  }
  
  note.updatedAt = new Date().toISOString();
  
  res.json(note);
});

app.put('/posts/:id', (req, res) => {
  const note = findNoteById(req.params.id);
  
  if (!note) {
    return res.status(404).json({
      error: 'Note not found',
      message: `Note with id ${req.params.id} does not exist`
    });
  }
  
  const { title, body } = req.body;
  
  if (!title || !body) {
    return res.status(400).json({
      error: 'Validation failed',
      message: 'Title and body are required for PUT requests'
    });
  }
  
  note.title = title.trim();
  note.body = body.trim();
  note.updatedAt = new Date().toISOString();
  
  res.json(note);
});

app.delete('/posts/:id', (req, res) => {
  const noteIndex = notes.findIndex(note => note.id === parseInt(req.params.id));
  
  if (noteIndex === -1) {
    return res.status(404).json({
      error: 'Note not found',
      message: `Note with id ${req.params.id} does not exist`
    });
  }
  
  notes.splice(noteIndex, 1);
  
  res.status(204).send();
});

app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    notesCount: notes.length
  });
});

app.get('/', (req, res) => {
  res.json({
    message: 'Notes Mock API Server',
    version: '1.0.0',
    endpoints: {
      'GET /posts': 'List notes with pagination (?_page=1&_limit=20)',
      'GET /posts/:id': 'Get single note',
      'POST /posts': 'Create new note',
      'PATCH /posts/:id': 'Update note',
      'DELETE /posts/:id': 'Delete note',
      'GET /health': 'Health check'
    }
  });
});

app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: 'Something went wrong on the server'
  });
});

app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    message: `Route ${req.originalUrl} does not exist`
  });
});

app.listen(PORT, () => {
  console.log(`Mock API Server running on port ${PORT}`);
  console.log(`Endpoints available at http://localhost:${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});