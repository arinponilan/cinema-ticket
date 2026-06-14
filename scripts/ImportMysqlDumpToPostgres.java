import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ImportMysqlDumpToPostgres {
    private static final Pattern INSERT_TABLE = Pattern.compile("INSERT INTO `?([a-zA-Z0-9_]+)`?");
    private static final String[] TABLE_ORDER = {
            "users",
            "movies",
            "schedules",
            "seats",
            "bookings",
            "booking_seats",
            "tickets",
            "transactions",
            "advertisements",
            "notifications"
    };

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            throw new IllegalArgumentException("Usage: java ImportMysqlDumpToPostgres <mysql-dump.sql>");
        }

        String url = requireEnv("DATABASE_URL");
        String username = requireEnv("DB_USERNAME");
        String password = requireEnv("DB_PASSWORD");
        Map<String, List<String>> insertsByTable = collectInserts(Path.of(args[0]));

        try (Connection connection = DriverManager.getConnection(url, username, password)) {
            connection.setAutoCommit(false);
            try (Statement statement = connection.createStatement()) {
                for (String table : TABLE_ORDER) {
                    for (String insert : insertsByTable.getOrDefault(table, List.of())) {
                        statement.executeUpdate(convertInsert(insert));
                    }
                }
                resetSequence(statement, "advertisements", "id");
                resetSequence(statement, "bookings", "id");
                resetSequence(statement, "movies", "id");
                resetSequence(statement, "notifications", "id");
                resetSequence(statement, "schedules", "schedule_id");
                resetSequence(statement, "seats", "id");
                resetSequence(statement, "tickets", "ticket_id");
                resetSequence(statement, "transactions", "transaction_id");
                resetSequence(statement, "users", "user_id");
            } catch (Exception exception) {
                connection.rollback();
                throw exception;
            }
            connection.commit();
        }

        int count = insertsByTable.values().stream().mapToInt(List::size).sum();
        System.out.println("Imported " + count + " INSERT statement(s) into PostgreSQL.");
    }

    private static Map<String, List<String>> collectInserts(Path dumpPath) throws Exception {
        Map<String, List<String>> insertsByTable = new HashMap<>();
        StringBuilder current = null;
        for (String line : Files.readAllLines(dumpPath)) {
            if (line.startsWith("INSERT INTO")) {
                current = new StringBuilder(line).append('\n');
                if (line.trim().endsWith(";")) {
                    addInsert(insertsByTable, current.toString());
                    current = null;
                }
            } else if (current != null) {
                current.append(line).append('\n');
                if (line.trim().endsWith(";")) {
                    addInsert(insertsByTable, current.toString());
                    current = null;
                }
            }
        }
        return insertsByTable;
    }

    private static void addInsert(Map<String, List<String>> insertsByTable, String insert) {
        Matcher matcher = INSERT_TABLE.matcher(insert);
        if (!matcher.find()) {
            throw new IllegalArgumentException("Cannot find INSERT table for: " + insert);
        }
        insertsByTable.computeIfAbsent(matcher.group(1), ignored -> new ArrayList<>()).add(insert);
    }

    private static String convertInsert(String sql) {
        String converted = sql
                .replace("`", "")
                .replace("b'0'", "false")
                .replace("b'1'", "true")
                .replace("\\'", "''");
        return converted.replaceFirst(";\\s*$", " ON CONFLICT DO NOTHING;");
    }

    private static void resetSequence(Statement statement, String table, String idColumn) throws Exception {
        String sql = """
                SELECT setval(
                    pg_get_serial_sequence('%s', '%s'),
                    COALESCE((SELECT MAX(%s) FROM %s), 1),
                    (SELECT COUNT(*) FROM %s) > 0
                )
                """.formatted(table, idColumn, idColumn, table, table);
        statement.execute(sql);
    }

    private static String requireEnv(String name) {
        String value = System.getenv(name);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Missing environment variable: " + name);
        }
        return value;
    }
}
