package K;

import D2.C0039n;
import android.content.Context;
import j0.InterfaceC0450a;
import java.io.File;

/* JADX INFO: loaded from: classes.dex */
public final class b extends J3.j implements I3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f835a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f836b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Object f837c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public /* synthetic */ b(int i4, Object obj, Object obj2) {
        super(0);
        this.f835a = i4;
        this.f836b = obj;
        this.f837c = obj2;
    }

    @Override // I3.a
    public final Object a() {
        switch (this.f835a) {
            case 0:
                Context context = (Context) this.f836b;
                ((c) this.f837c).getClass();
                String strConcat = "FlutterSharedPreferences".concat(".preferences_pb");
                J3.i.e(strConcat, "fileName");
                return new File(context.getApplicationContext().getFilesDir(), "datastore/".concat(strConcat));
            default:
                ((InterfaceC0450a) ((i0.b) this.f836b).f4464b).b((C0039n) this.f837c);
                return w3.i.f6729a;
        }
    }
}
