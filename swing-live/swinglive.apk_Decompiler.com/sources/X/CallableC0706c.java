package x;

import R0.k;
import android.content.Context;
import java.util.concurrent.Callable;

/* JADX INFO: renamed from: x.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class CallableC0706c implements Callable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6731a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ String f6732b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Context f6733c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ k f6734d;
    public final /* synthetic */ int e;

    public /* synthetic */ CallableC0706c(String str, Context context, k kVar, int i4, int i5) {
        this.f6731a = i5;
        this.f6732b = str;
        this.f6733c = context;
        this.f6734d = kVar;
        this.e = i4;
    }

    @Override // java.util.concurrent.Callable
    public final Object call() {
        switch (this.f6731a) {
            case 0:
                return AbstractC0709f.a(this.f6732b, this.f6733c, this.f6734d, this.e);
            default:
                try {
                    return AbstractC0709f.a(this.f6732b, this.f6733c, this.f6734d, this.e);
                } catch (Throwable unused) {
                    return new C0708e(-3);
                }
        }
    }
}
