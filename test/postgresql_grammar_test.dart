import 'package:test/test.dart';
import '../lib/src/database/migration/adapters/grammar/postgresql_grammar.dart';

void main() {
  group('PostgreSQL Grammar - PRIMARY KEY handling', () {
    late PostgreSqlGrammar grammar;

    setUp(() {
      grammar = PostgreSqlGrammar();
    });

    test('should preserve PRIMARY KEY when using table.id() pattern', () {
      final sql = '''
        CREATE TABLE `users` ( 
          `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT, 
          `username` VARCHAR(32) NULL, 
          PRIMARY KEY (`id`)
        )
      ''';

      final result = grammar.convertQuery(sql);
      
      // Should convert to SERIAL with PRIMARY KEY and remove duplicate PRIMARY KEY
      expect(result, contains('SERIAL NOT NULL PRIMARY KEY'));
      expect(result, isNot(contains('PRIMARY KEY ("id")')));
    });

    test('should preserve PRIMARY KEY when using BIGINT without AUTO_INCREMENT', () {
      final sql = '''
        CREATE TABLE `users` ( 
          `id` BIGINT(20) UNSIGNED NOT NULL, 
          `username` VARCHAR(32) NULL, 
          PRIMARY KEY (`id`)
        )
      ''';

      final result = grammar.convertQuery(sql);
      
      // Should preserve PRIMARY KEY constraint
      expect(result, contains('BIGINT NOT NULL'));
      expect(result, contains('PRIMARY KEY ("id")'));
    });

    test('should preserve PRIMARY KEY for non-SERIAL columns', () {
      final sql = '''
        CREATE TABLE `users` ( 
          `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT, 
          `email` VARCHAR(255) NOT NULL, 
          `code` VARCHAR(10) NOT NULL,
          PRIMARY KEY (`id`),
          UNIQUE KEY `unique_email` (`email`),
          PRIMARY KEY (`code`)
        )
      ''';

      final result = grammar.convertQuery(sql);
      
      // Should preserve PRIMARY KEY for code column but not for id (SERIAL)
      expect(result, contains('SERIAL NOT NULL PRIMARY KEY'));
      expect(result, isNot(contains('PRIMARY KEY ("id")')));
      expect(result, contains('PRIMARY KEY ("code")'));
    });
  });
}
