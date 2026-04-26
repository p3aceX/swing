package defpackage;

import B1.a;
import B2.b;
import D2.AbstractActivityC0029d;
import D2.v;
import I.C0053n;
import J3.i;
import O2.l;
import android.util.Log;
import e1.k;
import java.util.List;
import w3.f;
import x3.AbstractC0729i;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ e f3971a = new e();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final f f3972b = new f(new c(0));

    public static void a(e eVar, O2.f fVar, final b bVar) {
        eVar.getClass();
        i.e(fVar, "binaryMessenger");
        String strConcat = "".length() > 0 ? ".".concat("") : "";
        String strM = a.m("dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle", strConcat);
        f fVar2 = f3972b;
        Object obj = null;
        C0053n c0053n = new C0053n(fVar, strM, (l) fVar2.a(), obj, 5);
        if (bVar != null) {
            final int i4 = 0;
            c0053n.y(new O2.b() { // from class: d
                @Override // O2.b
                public final void d(Object obj2, v vVar) {
                    List listT;
                    List listT2;
                    AbstractActivityC0029d abstractActivityC0029d;
                    switch (i4) {
                        case 0:
                            b bVar2 = bVar;
                            i.c(obj2, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            Object obj3 = ((List) obj2).get(0);
                            i.c(obj3, "null cannot be cast to non-null type <root>.ToggleMessage");
                            try {
                                bVar2.a((b) obj3);
                                listT = k.x(null);
                                break;
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            return;
                        default:
                            try {
                                C0779j c0779j = bVar.f118a;
                                i.b(c0779j);
                                abstractActivityC0029d = (AbstractActivityC0029d) c0779j.f6969b;
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            if (abstractActivityC0029d == null) {
                                throw new B2.a();
                            }
                            i.b(abstractActivityC0029d);
                            listT2 = k.x(new a(Boolean.valueOf((abstractActivityC0029d.getWindow().getAttributes().flags & 128) != 0)));
                            vVar.f(listT2);
                            return;
                    }
                }
            });
        } else {
            c0053n.y(null);
        }
        C0053n c0053n2 = new C0053n(fVar, a.m("dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.isEnabled", strConcat), (l) fVar2.a(), obj, 5);
        if (bVar == null) {
            c0053n2.y(null);
        } else {
            final int i5 = 1;
            c0053n2.y(new O2.b() { // from class: d
                @Override // O2.b
                public final void d(Object obj2, v vVar) {
                    List listT;
                    List listT2;
                    AbstractActivityC0029d abstractActivityC0029d;
                    switch (i5) {
                        case 0:
                            b bVar2 = bVar;
                            i.c(obj2, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            Object obj3 = ((List) obj2).get(0);
                            i.c(obj3, "null cannot be cast to non-null type <root>.ToggleMessage");
                            try {
                                bVar2.a((b) obj3);
                                listT = k.x(null);
                                break;
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            return;
                        default:
                            try {
                                C0779j c0779j = bVar.f118a;
                                i.b(c0779j);
                                abstractActivityC0029d = (AbstractActivityC0029d) c0779j.f6969b;
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            if (abstractActivityC0029d == null) {
                                throw new B2.a();
                            }
                            i.b(abstractActivityC0029d);
                            listT2 = k.x(new a(Boolean.valueOf((abstractActivityC0029d.getWindow().getAttributes().flags & 128) != 0)));
                            vVar.f(listT2);
                            return;
                    }
                }
            });
        }
    }
}
