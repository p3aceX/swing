package H0;

import android.content.Context;

/* JADX INFO: loaded from: classes.dex */
public final class c {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final c f516b;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public b f517a;

    static {
        c cVar = new c();
        cVar.f517a = null;
        f516b = cVar;
    }

    public static b a(Context context) {
        b bVar;
        c cVar = f516b;
        synchronized (cVar) {
            try {
                if (cVar.f517a == null) {
                    if (context.getApplicationContext() != null) {
                        context = context.getApplicationContext();
                    }
                    cVar.f517a = new b(context);
                }
                bVar = cVar.f517a;
            } catch (Throwable th) {
                throw th;
            }
        }
        return bVar;
    }
}
