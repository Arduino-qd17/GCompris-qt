/* GComprisServer - MessageHandler.h
 *
 * Copyright (C) 2016 Johnny Jazeix <jazeix@gmail.com>
 *
 * Authors:
 *   Johnny Jazeix <jazeix@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, see <http://www.gnu.org/licenses/>.
 */
#ifndef MESSAGEHANDLER_H
#define MESSAGEHANDLER_H

#include "Messages.h"
#include "ClientData.h"
#include <QObject>
#include <QtQml>

class MessageHandler: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QList<QObject*> clients MEMBER m_clients NOTIFY newClients)

private:
    MessageHandler();  // prohibit external creation, we are a singleton!
    static MessageHandler* _instance;  // singleton instance
    
public:
    /**
     * Registers MessageHandler singleton in the QML engine.
     */
    static void init();
    static QObject *systeminfoProvider(QQmlEngine *engine,
            QJSEngine *scriptEngine);
    static MessageHandler* getInstance();

public slots:
    void onLoginReceived(const Login &data);
    void onActivityDataReceived(const ActivityData &act);
    void onNewClientReceived(const ClientData &client);
    void onClientDisconnected(const ClientData &client);

signals:
    void newClients();

private:
    ClientData *getClientData(const ClientData &cd);
    QList<QObject*> m_clients;
};

#endif
