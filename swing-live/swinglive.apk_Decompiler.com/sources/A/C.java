package A;

import java.lang.reflect.Field;
import java.util.WeakHashMap;

/* JADX INFO: loaded from: classes.dex */
public abstract class C {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static Field f4a = null;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static boolean f5b = false;

    static {
        new WeakHashMap();
    }

    /* JADX WARN: Removed duplicated region for block: B:17:0x0033 A[Catch: all -> 0x0036, TRY_LEAVE, TryCatch #0 {all -> 0x0036, blocks: (B:15:0x0029, B:17:0x0033), top: B:32:0x0029 }] */
    /* JADX WARN: Removed duplicated region for block: B:20:0x0038  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static void a(android.view.ViewGroup r4, A.C0002b r5) {
        /*
            r0 = 0
            r1 = 1
            if (r5 != 0) goto L42
            int r2 = android.os.Build.VERSION.SDK_INT
            r3 = 29
            if (r2 < r3) goto Lf
            android.view.View$AccessibilityDelegate r2 = A.AbstractC0024y.a(r4)
            goto L39
        Lf:
            boolean r2 = A.C.f5b
            if (r2 == 0) goto L14
            goto L38
        L14:
            java.lang.reflect.Field r2 = A.C.f4a
            if (r2 != 0) goto L29
            java.lang.Class<android.view.View> r2 = android.view.View.class
            java.lang.String r3 = "mAccessibilityDelegate"
            java.lang.reflect.Field r2 = r2.getDeclaredField(r3)     // Catch: java.lang.Throwable -> L26
            A.C.f4a = r2     // Catch: java.lang.Throwable -> L26
            r2.setAccessible(r1)     // Catch: java.lang.Throwable -> L26
            goto L29
        L26:
            A.C.f5b = r1
            goto L38
        L29:
            java.lang.reflect.Field r2 = A.C.f4a     // Catch: java.lang.Throwable -> L36
            java.lang.Object r2 = r2.get(r4)     // Catch: java.lang.Throwable -> L36
            boolean r3 = r2 instanceof android.view.View.AccessibilityDelegate     // Catch: java.lang.Throwable -> L36
            if (r3 == 0) goto L38
            android.view.View$AccessibilityDelegate r2 = (android.view.View.AccessibilityDelegate) r2     // Catch: java.lang.Throwable -> L36
            goto L39
        L36:
            A.C.f5b = r1
        L38:
            r2 = r0
        L39:
            boolean r2 = r2 instanceof A.C0001a
            if (r2 == 0) goto L42
            A.b r5 = new A.b
            r5.<init>()
        L42:
            int r2 = r4.getImportantForAccessibility()
            if (r2 != 0) goto L4b
            r4.setImportantForAccessibility(r1)
        L4b:
            if (r5 != 0) goto L4e
            goto L50
        L4e:
            A.a r0 = r5.f40b
        L50:
            r4.setAccessibilityDelegate(r0)
            return
        */
        throw new UnsupportedOperationException("Method not decompiled: A.C.a(android.view.ViewGroup, A.b):void");
    }
}
