package androidx.datastore.preferences.protobuf;

/* JADX INFO: loaded from: classes.dex */
public final class H {
    public static G a(Object obj, Object obj2) {
        G gB = (G) obj;
        G g4 = (G) obj2;
        if (!g4.isEmpty()) {
            if (!gB.f2904a) {
                gB = gB.b();
            }
            gB.a();
            if (!g4.isEmpty()) {
                gB.putAll(g4);
            }
        }
        return gB;
    }
}
