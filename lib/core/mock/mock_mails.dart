import '../models/mail_model.dart';

abstract final class MockMails {
  static const folderLabels = ['Principal', 'Social', 'Promociones'];

  static List<MailModel> all() {
    return [
      const MailModel(
        id: 'mock_mail_laura',
        folderIndex: 0,
        senderName: 'Laura M.',
        subject: '¿Nos vemos el martes?',
        preview: 'Hola José, avísame si te viene bien…',
      ),
      const MailModel(
        id: 'mock_mail_banco',
        folderIndex: 0,
        senderName: 'Banco Demo',
        subject: 'Resumen de tu cuenta',
        preview: 'No es un correo real.',
      ),
      const MailModel(
        id: 'mock_mail_futbol',
        folderIndex: 1,
        senderName: 'Equipo fútbol',
        subject: 'Partido el domingo',
        preview: 'Llevamos camisetas nuevas (mock).',
      ),
      const MailModel(
        id: 'mock_mail_ux',
        folderIndex: 2,
        senderName: 'Newsletter UX',
        subject: '5 tips de accesibilidad',
        preview: 'Promo simulada · sin enlaces.',
      ),
      const MailModel(
        id: 'mock_mail_muebles',
        folderIndex: 2,
        senderName: 'Tienda muebles',
        subject: '-20% esta semana',
        preview: 'Oferta ficticia.',
      ),
    ];
  }
}
