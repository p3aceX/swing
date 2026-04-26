package T;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;

/* JADX INFO: loaded from: classes.dex */
public final class a extends Handler {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ b f1861a;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public a(b bVar, Looper looper) {
        super(looper);
        this.f1861a = bVar;
    }

    @Override // android.os.Handler
    public final void handleMessage(Message message) {
        int size;
        H0.a[] aVarArr;
        if (message.what != 1) {
            super.handleMessage(message);
            return;
        }
        b bVar = this.f1861a;
        do {
            synchronized (bVar.f1864b) {
                try {
                    size = bVar.f1866d.size();
                    if (size <= 0) {
                        return;
                    }
                    aVarArr = new H0.a[size];
                    bVar.f1866d.toArray(aVarArr);
                    bVar.f1866d.clear();
                } catch (Throwable th) {
                    throw th;
                }
            }
        } while (size <= 0);
        H0.a aVar = aVarArr[0];
        throw null;
    }
}
