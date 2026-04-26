package T;

import O.AbstractActivityC0114z;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import java.util.ArrayList;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public final class b {
    public static final Object e = new Object();

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static b f1862f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f1863a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final HashMap f1864b = new HashMap();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final HashMap f1865c = new HashMap();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final ArrayList f1866d = new ArrayList();

    public b(Context context) {
        this.f1863a = context;
        new a(this, context.getMainLooper());
    }

    public static b a(AbstractActivityC0114z abstractActivityC0114z) {
        b bVar;
        synchronized (e) {
            try {
                if (f1862f == null) {
                    f1862f = new b(abstractActivityC0114z.getApplicationContext());
                }
                bVar = f1862f;
            } catch (Throwable th) {
                throw th;
            }
        }
        return bVar;
    }

    public final void b(Intent intent) {
        synchronized (this.f1864b) {
            try {
                intent.getAction();
                String strResolveTypeIfNeeded = intent.resolveTypeIfNeeded(this.f1863a.getContentResolver());
                intent.getData();
                String scheme = intent.getScheme();
                intent.getCategories();
                boolean z4 = (intent.getFlags() & 8) != 0;
                if (z4) {
                    Log.v("LocalBroadcastManager", "Resolving type " + strResolveTypeIfNeeded + " scheme " + scheme + " of intent " + intent);
                }
                ArrayList arrayList = (ArrayList) this.f1865c.get(intent.getAction());
                if (arrayList != null) {
                    if (z4) {
                        Log.v("LocalBroadcastManager", "Action list: " + arrayList);
                    }
                    if (arrayList.size() > 0) {
                        if (arrayList.get(0) != null) {
                            throw new ClassCastException();
                        }
                        if (!z4) {
                            throw null;
                        }
                        throw null;
                    }
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }
}
