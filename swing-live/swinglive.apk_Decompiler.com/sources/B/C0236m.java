package b;

import I.Q;
import I.c0;
import O.C0102m;
import O.E;
import O.M;
import O.N;
import O.Y;
import O.Z;
import android.util.Log;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import x3.AbstractC0728h;
import x3.C0725e;

/* JADX INFO: renamed from: b.m, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0236m extends J3.j implements I3.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3246a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f3247b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public /* synthetic */ C0236m(Object obj, int i4) {
        super(1);
        this.f3246a = i4;
        this.f3247b = obj;
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        Object objPrevious;
        Object objPrevious2;
        switch (this.f3246a) {
            case 0:
                J3.i.e((C0225b) obj, "backEvent");
                u uVar = (u) this.f3247b;
                C0725e c0725e = uVar.f3264b;
                c0725e.getClass();
                ListIterator listIterator = c0725e.listIterator(c0725e.f6781c);
                while (true) {
                    if (listIterator.hasPrevious()) {
                        objPrevious = listIterator.previous();
                        if (((E) objPrevious).f1209a) {
                        }
                    } else {
                        objPrevious = null;
                    }
                }
                E e = (E) objPrevious;
                uVar.f3265c = e;
                if (e != null) {
                    boolean zJ = N.J(3);
                    N n4 = e.f1212d;
                    if (zJ) {
                        Log.d("FragmentManager", "handleOnBackStarted. PREDICTIVE_BACK = true fragment manager " + n4);
                    }
                    n4.w();
                    n4.x(new M(n4), false);
                }
                return w3.i.f6729a;
            case 1:
                C0225b c0225b = (C0225b) obj;
                J3.i.e(c0225b, "backEvent");
                u uVar2 = (u) this.f3247b;
                E e4 = uVar2.f3265c;
                if (e4 == null) {
                    C0725e c0725e2 = uVar2.f3264b;
                    c0725e2.getClass();
                    ListIterator listIterator2 = c0725e2.listIterator(c0725e2.f6781c);
                    while (true) {
                        if (listIterator2.hasPrevious()) {
                            objPrevious2 = listIterator2.previous();
                            if (((E) objPrevious2).f1209a) {
                            }
                        } else {
                            objPrevious2 = null;
                        }
                    }
                    e4 = (E) objPrevious2;
                }
                if (e4 != null) {
                    boolean zJ2 = N.J(2);
                    N n5 = e4.f1212d;
                    if (zJ2) {
                        Log.v("FragmentManager", "handleOnBackProgressed. PREDICTIVE_BACK = true fragment manager " + n5);
                    }
                    if (n5.f1243h != null) {
                        for (C0102m c0102m : n5.f(new ArrayList(Collections.singletonList(n5.f1243h)), 0, 1)) {
                            c0102m.getClass();
                            if (N.J(2)) {
                                Log.v("FragmentManager", "SpecialEffectsController: Processing Progress " + c0225b.f3207c);
                            }
                            ArrayList arrayList = c0102m.f1355c;
                            ArrayList arrayList2 = new ArrayList();
                            Iterator it = arrayList.iterator();
                            while (it.hasNext()) {
                                ((Z) it.next()).getClass();
                                x3.n.W(arrayList2, null);
                            }
                            List listI0 = AbstractC0728h.i0(AbstractC0728h.m0(arrayList2));
                            int size = listI0.size();
                            for (int i4 = 0; i4 < size; i4++) {
                                ((Y) listI0.get(i4)).b(c0225b, c0102m.f1353a);
                            }
                        }
                        Iterator it2 = n5.f1248m.iterator();
                        if (it2.hasNext()) {
                            it2.next().getClass();
                            throw new ClassCastException();
                        }
                    }
                }
                return w3.i.f6729a;
            default:
                Throwable th = (Throwable) obj;
                Q q4 = (Q) this.f3247b;
                if (th != null) {
                    q4.f603n.A(new c0(th));
                }
                if (q4.f605p.f6723b != w3.h.f6728a) {
                    ((I.Z) q4.f605p.a()).close();
                }
                return w3.i.f6729a;
        }
    }
}
