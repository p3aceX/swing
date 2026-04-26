package O2;

import I.C0053n;
import android.util.Log;
import java.nio.ByteBuffer;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class a implements e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1446a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f1447b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Object f1448c;

    public /* synthetic */ a(int i4, Object obj, Object obj2) {
        this.f1446a = i4;
        this.f1448c = obj;
        this.f1447b = obj2;
    }

    @Override // O2.e
    public final void a(ByteBuffer byteBuffer) {
        switch (this.f1446a) {
            case 0:
                C0053n c0053n = (C0053n) this.f1448c;
                try {
                    ((c) this.f1447b).f(((l) c0053n.f708d).a(byteBuffer));
                } catch (RuntimeException e) {
                    Log.e("BasicMessageChannel#" + ((String) c0053n.f707c), "Failed to handle message reply", e);
                    return;
                }
                break;
            default:
                C0747k c0747k = (C0747k) this.f1448c;
                N2.j jVar = (N2.j) this.f1447b;
                try {
                    if (byteBuffer == null) {
                        jVar.getClass();
                    } else {
                        try {
                            jVar.c(((n) c0747k.f6833d).d(byteBuffer));
                        } catch (i e4) {
                            jVar.a(e4.f1452b, e4.f1451a, e4.getMessage());
                        }
                    }
                } catch (RuntimeException e5) {
                    Log.e("MethodChannel#" + ((String) c0747k.f6832c), "Failed to handle method call result", e5);
                    return;
                }
                break;
        }
    }
}
