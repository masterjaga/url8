import 'reflect-metadata';
import express from 'express';
import bodyParser from 'body-parser';
import lusca from 'lusca';
import helmet from 'helmet';

import routes from './routes';
import * as middlewares from './middlewares';
import { initDb } from './db';
import { EventManagerServiceImpl } from './services/impl/eventManager';

initDb();
EventManagerServiceImpl.getInstance().registerListeners();

// Create Express server
const app = express();

// Express configuration
app.set('port', process.env.PORT || 3000);
app.use(bodyParser.json());
app.use(helmet());
app.use(lusca.xframe('SAMEORIGIN'));
app.use(lusca.xssProtection(true));

app.use(middlewares.formatResponse);

app.use(routes);

app.use(middlewares.notFound);
app.use(middlewares.errorHandler);

export default app;
