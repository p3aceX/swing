package androidx.lifecycle;

import java.io.Closeable;
import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;

/* JADX INFO: loaded from: classes.dex */
public final class H {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final LinkedHashMap f3062a = new LinkedHashMap();

    public final void a() {
        for (F f4 : this.f3062a.values()) {
            HashMap map = f4.f3058a;
            if (map != null) {
                synchronized (map) {
                    try {
                        for (Object obj : f4.f3058a.values()) {
                            if (obj instanceof Closeable) {
                                try {
                                    ((Closeable) obj).close();
                                } catch (IOException e) {
                                    throw new RuntimeException(e);
                                }
                            }
                        }
                    } finally {
                    }
                }
            }
            LinkedHashSet linkedHashSet = f4.f3059b;
            if (linkedHashSet != null) {
                synchronized (linkedHashSet) {
                    try {
                        for (Closeable closeable : f4.f3059b) {
                            if (closeable != null) {
                                try {
                                    closeable.close();
                                } catch (IOException e4) {
                                    throw new RuntimeException(e4);
                                }
                            }
                        }
                    } finally {
                    }
                }
                f4.f3059b.clear();
            }
            f4.a();
        }
        this.f3062a.clear();
    }
}
