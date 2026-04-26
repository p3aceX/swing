package N2;

import D2.v;
import N2.j;
import O.RunnableC0093d;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import java.util.Objects;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1166a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f1167b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f1168c;

    public /* synthetic */ j(int i4, Object obj, Object obj2) {
        this.f1166a = i4;
        this.f1168c = obj;
        this.f1167b = obj2;
    }

    public final void a(final Object obj, final String str, final String str2) {
        switch (this.f1166a) {
            case 0:
                Log.e("RestorationChannel", "Error " + str + " while sending restoration data to framework: " + str2);
                break;
            case 1:
                ((F2.g) this.f1167b).a(((O2.n) ((C0747k) ((v) this.f1168c).f261c).f6833d).f(obj, str, str2));
                break;
            default:
                ((Handler) this.f1168c).post(new Runnable() { // from class: w1.b
                    @Override // java.lang.Runnable
                    public final void run() {
                        ((j) this.f6702a.f1167b).a(obj, str, str2);
                    }
                });
                break;
        }
    }

    public void b() {
        switch (this.f1166a) {
            case 1:
                ((F2.g) this.f1167b).a(null);
                break;
            default:
                Handler handler = (Handler) this.f1168c;
                j jVar = (j) this.f1167b;
                Objects.requireNonNull(jVar);
                handler.post(new F1.a(jVar, 19));
                break;
        }
    }

    public final void c(Object obj) {
        switch (this.f1166a) {
            case 0:
                ((k) this.f1168c).f1170b = (byte[]) this.f1167b;
                break;
            case 1:
                ((F2.g) this.f1167b).a(((O2.n) ((C0747k) ((v) this.f1168c).f261c).f6833d).b(obj));
                break;
            default:
                ((Handler) this.f1168c).post(new RunnableC0093d(13, this, obj));
                break;
        }
    }

    public j(j jVar) {
        this.f1166a = 2;
        this.f1168c = new Handler(Looper.getMainLooper());
        this.f1167b = jVar;
    }
}
