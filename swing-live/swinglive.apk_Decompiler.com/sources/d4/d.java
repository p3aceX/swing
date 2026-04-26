package d4;

import K.j;
import java.io.PrintStream;

/* JADX INFO: loaded from: classes.dex */
public abstract class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final int f3961a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final int f3962b;

    static {
        int i4;
        String[] strArr = {"System.out", "stdout", "sysout"};
        String property = System.getProperty("slf4j.internal.report.stream");
        int i5 = 2;
        if (property == null || property.isEmpty()) {
            i4 = 1;
        } else {
            for (int i6 = 0; i6 < 3; i6++) {
                if (strArr[i6].equalsIgnoreCase(property)) {
                    i4 = 2;
                    break;
                }
            }
            i4 = 1;
        }
        f3961a = i4;
        String property2 = System.getProperty("slf4j.internal.verbosity");
        if (property2 != null && !property2.isEmpty()) {
            if (property2.equalsIgnoreCase("DEBUG")) {
                i5 = 1;
            } else if (property2.equalsIgnoreCase("ERROR")) {
                i5 = 4;
            } else if (property2.equalsIgnoreCase("WARN")) {
                i5 = 3;
            }
        }
        f3962b = i5;
    }

    public static final void a(String str, Throwable th) {
        b().println("SLF4J(E): " + str);
        b().println("SLF4J(E): Reported exception:");
        th.printStackTrace(b());
    }

    public static PrintStream b() {
        return j.b(f3961a) != 1 ? System.err : System.out;
    }

    public static final void c(String str) {
        if (j.b(3) >= j.b(f3962b)) {
            b().println("SLF4J(W): " + str);
        }
    }
}
