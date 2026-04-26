package Q3;

import android.graphics.Typeface;
import android.os.Looper;
import android.os.SystemClock;
import android.util.Log;
import android.widget.TextView;
import androidx.appcompat.widget.ActionMenuView;
import com.google.android.gms.internal.p002firebaseauthapi.zzafm;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import j1.C0461f;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.Map;
import k.C0489f;
import k.C0492i;
import k.C0502t;
import k.C0503u;
import l.C0517a;
import l.C0520d;
import l3.C0523A;
import x.C0707d;
import y0.C0740d;
import y3.C0768i;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class x0 implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1668a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f1669b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f1670c;

    public /* synthetic */ x0(int i4, Object obj, Object obj2) {
        this.f1668a = i4;
        this.f1669b = obj;
        this.f1670c = obj2;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r3v6, types: [j1.f, k1.p] */
    /* JADX WARN: Type inference fix 'apply assigned field type' failed
    java.lang.UnsupportedOperationException: ArgType.getObject(), call class: class jadx.core.dex.instructions.args.ArgType$UnknownArg
    	at jadx.core.dex.instructions.args.ArgType.getObject(ArgType.java:593)
    	at jadx.core.dex.attributes.nodes.ClassTypeVarsAttr.getTypeVarsMapFor(ClassTypeVarsAttr.java:35)
    	at jadx.core.dex.nodes.utils.TypeUtils.replaceClassGenerics(TypeUtils.java:177)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.insertExplicitUseCast(FixTypesVisitor.java:397)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.tryFieldTypeWithNewCasts(FixTypesVisitor.java:359)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.applyFieldType(FixTypesVisitor.java:309)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.visit(FixTypesVisitor.java:94)
     */
    @Override // java.lang.Runnable
    public final void run() throws IOException {
        boolean z4;
        switch (this.f1668a) {
            case 0:
                ((C0141m) this.f1670c).B((C0120b0) this.f1669b);
                return;
            case 1:
                S.a aVar = (S.a) this.f1670c;
                Object obj = this.f1669b;
                if (!aVar.f1719c.get()) {
                    C0740d c0740d = aVar.e;
                    if (c0740d.f6818g != aVar) {
                        if (c0740d.f6819h == aVar) {
                            SystemClock.uptimeMillis();
                            c0740d.f6819h = null;
                            c0740d.b();
                        }
                    } else if (!c0740d.f6815c) {
                        SystemClock.uptimeMillis();
                        c0740d.f6818g = null;
                        R.a aVar2 = c0740d.f6813a;
                        if (aVar2 != null) {
                            if (Looper.myLooper() == Looper.getMainLooper()) {
                                aVar2.h(obj);
                            } else {
                                synchronized (aVar2.f3090a) {
                                    z4 = aVar2.f3094f == androidx.lifecycle.u.f3089k;
                                    aVar2.f3094f = obj;
                                    break;
                                }
                                if (z4) {
                                    C0517a c0517aC0 = C0517a.c0();
                                    F.b bVar = aVar2.f3098j;
                                    C0520d c0520d = c0517aC0.f5566c;
                                    if (c0520d.f5569d == null) {
                                        synchronized (c0520d.f5568c) {
                                            try {
                                                if (c0520d.f5569d == null) {
                                                    c0520d.f5569d = C0520d.c0(Looper.getMainLooper());
                                                }
                                            } finally {
                                            }
                                        }
                                    }
                                    c0520d.f5569d.post(bVar);
                                }
                            }
                        }
                    }
                    break;
                } else {
                    C0740d c0740d2 = aVar.e;
                    if (c0740d2.f6819h == aVar) {
                        SystemClock.uptimeMillis();
                        c0740d2.f6819h = null;
                        c0740d2.b();
                    }
                }
                aVar.f1718b = 3;
                return;
            case 2:
                int i4 = 0;
                while (true) {
                    try {
                        ((Runnable) this.f1669b).run();
                    } catch (Throwable th) {
                        F.o(th, C0768i.f6945a);
                    }
                    Runnable runnableE = ((V3.h) this.f1670c).E();
                    if (runnableE == null) {
                        return;
                    }
                    try {
                        this.f1669b = runnableE;
                        i4++;
                        if (i4 >= 16) {
                            V3.h hVar = (V3.h) this.f1670c;
                            if (V3.b.j(hVar.f2229d, hVar)) {
                                V3.h hVar2 = (V3.h) this.f1670c;
                                V3.b.i(hVar2.f2229d, hVar2, this);
                                return;
                            }
                        }
                    } catch (Throwable th2) {
                        V3.h hVar3 = (V3.h) this.f1670c;
                        synchronized (hVar3.f2231m) {
                            V3.h.f2227n.decrementAndGet(hVar3);
                            throw th2;
                        }
                    }
                    break;
                }
                break;
            case 3:
                Map map = (Map) ((WeakReference) this.f1669b).get();
                if (map == null) {
                    Log.d("ImageStreamReader", "Image buffer was dropped by garbage collector.");
                    return;
                } else {
                    ((O2.g) this.f1670c).a(map);
                    return;
                }
            case 4:
                C0492i c0492i = (C0492i) this.f1670c;
                j.j jVar = c0492i.f5381c;
                ActionMenuView actionMenuView = c0492i.f5384m;
                if (actionMenuView != null && actionMenuView.getWindowToken() != null) {
                    C0489f c0489f = (C0489f) this.f1669b;
                    if (c0489f.b()) {
                        c0492i.f5394x = c0489f;
                    } else if (c0489f.e != null) {
                        c0489f.d(0, 0, false, false);
                        c0492i.f5394x = c0489f;
                    }
                }
                c0492i.f5396z = null;
                return;
            case 5:
                C0503u c0503u = (C0503u) ((WeakReference) this.f1669b).get();
                if (c0503u != null && c0503u.f5472m) {
                    TextView textView = c0503u.f5461a;
                    Typeface typeface = (Typeface) this.f1670c;
                    textView.setTypeface(typeface);
                    c0503u.f5471l = typeface;
                    return;
                }
                return;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                FirebaseAuth firebaseAuth = FirebaseAuth.getInstance(g1.f.d((String) this.f1669b));
                j1.l lVar = firebaseAuth.f3845f;
                if (lVar != null) {
                    zzafm zzafmVar = ((k1.e) lVar).f5512a;
                    zzafmVar.zzg();
                    Task<B.k> taskZza = firebaseAuth.e.zza(firebaseAuth.f3841a, lVar, zzafmVar.zzd(), (k1.p) new C0461f(firebaseAuth, 1));
                    k1.h.e.e("Token refreshing started", new Object[0]);
                    taskZza.addOnFailureListener(new C0779j(this, 28));
                    return;
                }
                return;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                C0502t c0502t = (C0502t) ((C0523A) this.f1669b).f5626a;
                if (c0502t != null) {
                    c0502t.d((Typeface) this.f1670c);
                    return;
                }
                return;
            default:
                ((C0707d) this.f1669b).accept(this.f1670c);
                return;
        }
    }

    public /* synthetic */ x0(Object obj, Object obj2, int i4, boolean z4) {
        this.f1668a = i4;
        this.f1670c = obj;
        this.f1669b = obj2;
    }

    public x0(k1.h hVar, String str) {
        this.f1668a = 6;
        this.f1670c = hVar;
        com.google.android.gms.common.internal.F.d(str);
        this.f1669b = str;
    }

    public x0(O2.g gVar) {
        this.f1668a = 3;
        this.f1670c = gVar;
    }
}
