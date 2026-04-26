package u1;

import java.util.Iterator;
import java.util.Set;

/* JADX INFO: renamed from: u1.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0689b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f6637a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0690c f6638b;

    public C0689b(Set set, C0690c c0690c) {
        this.f6637a = a(set);
        this.f6638b = c0690c;
    }

    public static String a(Set set) {
        StringBuilder sb = new StringBuilder();
        Iterator it = set.iterator();
        while (it.hasNext()) {
            C0688a c0688a = (C0688a) it.next();
            sb.append(c0688a.f6635a);
            sb.append('/');
            sb.append(c0688a.f6636b);
            if (it.hasNext()) {
                sb.append(' ');
            }
        }
        return sb.toString();
    }
}
