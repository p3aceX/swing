package g1;

import android.util.Log;
import com.google.android.gms.common.api.internal.InterfaceC0254b;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.concurrent.atomic.AtomicReference;

/* JADX INFO: loaded from: classes.dex */
public final class d implements InterfaceC0254b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final AtomicReference f4302a = new AtomicReference();

    @Override // com.google.android.gms.common.api.internal.InterfaceC0254b
    public final void a(boolean z4) {
        synchronized (f.f4305i) {
            try {
                for (f fVar : new ArrayList(f.f4306j.values())) {
                    if (fVar.e.get()) {
                        Log.d("FirebaseApp", "Notifying background state change listeners.");
                        Iterator it = fVar.f4313h.iterator();
                        while (it.hasNext()) {
                            f fVar2 = ((c) it.next()).f4301a;
                            if (z4) {
                                fVar2.getClass();
                            } else {
                                ((p1.c) fVar2.f4312g.get()).b();
                            }
                        }
                    }
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }
}
