package p1;

import android.content.Context;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import java.util.Set;
import java.util.concurrent.Executor;
import q1.InterfaceC0634a;

/* JADX INFO: loaded from: classes.dex */
public final class c implements e, f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final l1.f f6181a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Context f6182b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final InterfaceC0634a f6183c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Set f6184d;
    public final Executor e;

    public c(Context context, String str, Set set, InterfaceC0634a interfaceC0634a, Executor executor) {
        this.f6181a = new l1.f(1, context, str);
        this.f6184d = set;
        this.e = executor;
        this.f6183c = interfaceC0634a;
        this.f6182b = context;
    }

    public final Task a() {
        if (!w.g.a(this.f6182b)) {
            return Tasks.forResult("");
        }
        return Tasks.call(this.e, new b(this, 0));
    }

    public final void b() {
        if (this.f6184d.size() <= 0) {
            Tasks.forResult(null);
        } else if (!w.g.a(this.f6182b)) {
            Tasks.forResult(null);
        } else {
            Tasks.call(this.e, new b(this, 1));
        }
    }
}
