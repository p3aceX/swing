package O;

import I.C0053n;
import a.AbstractC0184a;
import android.os.Bundle;
import android.os.Looper;
import android.os.Parcelable;
import android.util.Log;
import android.util.SparseArray;
import android.view.View;
import android.view.ViewGroup;
import androidx.lifecycle.EnumC0222h;
import b.C0229f;
import b.C0241r;
import b.InterfaceC0226c;
import com.swing.live.R;
import java.io.FileDescriptor;
import java.io.PrintWriter;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;
import u1.C0690c;
import y0.C0747k;
import z.InterfaceC0769a;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class N {

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public final p1.d f1223A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public C0747k f1224B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public C0747k f1225C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public C0747k f1226D;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public ArrayDeque f1227E;

    /* JADX INFO: renamed from: F, reason: collision with root package name */
    public boolean f1228F;

    /* JADX INFO: renamed from: G, reason: collision with root package name */
    public boolean f1229G;

    /* JADX INFO: renamed from: H, reason: collision with root package name */
    public boolean f1230H;

    /* JADX INFO: renamed from: I, reason: collision with root package name */
    public boolean f1231I;
    public boolean J;

    /* JADX INFO: renamed from: K, reason: collision with root package name */
    public ArrayList f1232K;

    /* JADX INFO: renamed from: L, reason: collision with root package name */
    public ArrayList f1233L;

    /* JADX INFO: renamed from: M, reason: collision with root package name */
    public ArrayList f1234M;

    /* JADX INFO: renamed from: N, reason: collision with root package name */
    public Q f1235N;

    /* JADX INFO: renamed from: O, reason: collision with root package name */
    public final F.b f1236O;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f1238b;
    public ArrayList e;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public b.u f1242g;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final ArrayList f1248m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final D2.v f1249n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final CopyOnWriteArrayList f1250o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final D f1251p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final D f1252q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final D f1253r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final D f1254s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final F f1255t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public int f1256u;
    public C0113y v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public AbstractC0184a f1257w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public AbstractComponentCallbacksC0109u f1258x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public AbstractComponentCallbacksC0109u f1259y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public final G f1260z;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ArrayList f1237a = new ArrayList();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0053n f1239c = new C0053n(4);

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public ArrayList f1240d = new ArrayList();

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final C f1241f = new C(this);

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public C0090a f1243h = null;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final E f1244i = new E(this);

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final AtomicInteger f1245j = new AtomicInteger();

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final Map f1246k = Collections.synchronizedMap(new HashMap());

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final Map f1247l = Collections.synchronizedMap(new HashMap());

    /* JADX WARN: Type inference failed for: r0v15, types: [O.D] */
    /* JADX WARN: Type inference failed for: r0v16, types: [O.D] */
    /* JADX WARN: Type inference failed for: r0v17, types: [O.D] */
    /* JADX WARN: Type inference failed for: r0v18, types: [O.D] */
    public N() {
        Collections.synchronizedMap(new HashMap());
        this.f1248m = new ArrayList();
        this.f1249n = new D2.v(this);
        this.f1250o = new CopyOnWriteArrayList();
        final int i4 = 0;
        this.f1251p = new InterfaceC0769a(this) { // from class: O.D

            /* JADX INFO: renamed from: b, reason: collision with root package name */
            public final /* synthetic */ N f1208b;

            {
                this.f1208b = this;
            }

            @Override // z.InterfaceC0769a
            public final void accept(Object obj) {
                switch (i4) {
                    case 0:
                        N n4 = this.f1208b;
                        if (n4.L()) {
                            n4.i(false);
                        }
                        break;
                    case 1:
                        Integer num = (Integer) obj;
                        N n5 = this.f1208b;
                        if (n5.L() && num.intValue() == 80) {
                            n5.m(false);
                            break;
                        }
                        break;
                    case 2:
                        q.k kVar = (q.k) obj;
                        N n6 = this.f1208b;
                        if (n6.L()) {
                            boolean z4 = kVar.f6216a;
                            n6.n(false);
                        }
                        break;
                    default:
                        q.x xVar = (q.x) obj;
                        N n7 = this.f1208b;
                        if (n7.L()) {
                            boolean z5 = xVar.f6240a;
                            n7.s(false);
                        }
                        break;
                }
            }
        };
        final int i5 = 1;
        this.f1252q = new InterfaceC0769a(this) { // from class: O.D

            /* JADX INFO: renamed from: b, reason: collision with root package name */
            public final /* synthetic */ N f1208b;

            {
                this.f1208b = this;
            }

            @Override // z.InterfaceC0769a
            public final void accept(Object obj) {
                switch (i5) {
                    case 0:
                        N n4 = this.f1208b;
                        if (n4.L()) {
                            n4.i(false);
                        }
                        break;
                    case 1:
                        Integer num = (Integer) obj;
                        N n5 = this.f1208b;
                        if (n5.L() && num.intValue() == 80) {
                            n5.m(false);
                            break;
                        }
                        break;
                    case 2:
                        q.k kVar = (q.k) obj;
                        N n6 = this.f1208b;
                        if (n6.L()) {
                            boolean z4 = kVar.f6216a;
                            n6.n(false);
                        }
                        break;
                    default:
                        q.x xVar = (q.x) obj;
                        N n7 = this.f1208b;
                        if (n7.L()) {
                            boolean z5 = xVar.f6240a;
                            n7.s(false);
                        }
                        break;
                }
            }
        };
        final int i6 = 2;
        this.f1253r = new InterfaceC0769a(this) { // from class: O.D

            /* JADX INFO: renamed from: b, reason: collision with root package name */
            public final /* synthetic */ N f1208b;

            {
                this.f1208b = this;
            }

            @Override // z.InterfaceC0769a
            public final void accept(Object obj) {
                switch (i6) {
                    case 0:
                        N n4 = this.f1208b;
                        if (n4.L()) {
                            n4.i(false);
                        }
                        break;
                    case 1:
                        Integer num = (Integer) obj;
                        N n5 = this.f1208b;
                        if (n5.L() && num.intValue() == 80) {
                            n5.m(false);
                            break;
                        }
                        break;
                    case 2:
                        q.k kVar = (q.k) obj;
                        N n6 = this.f1208b;
                        if (n6.L()) {
                            boolean z4 = kVar.f6216a;
                            n6.n(false);
                        }
                        break;
                    default:
                        q.x xVar = (q.x) obj;
                        N n7 = this.f1208b;
                        if (n7.L()) {
                            boolean z5 = xVar.f6240a;
                            n7.s(false);
                        }
                        break;
                }
            }
        };
        final int i7 = 3;
        this.f1254s = new InterfaceC0769a(this) { // from class: O.D

            /* JADX INFO: renamed from: b, reason: collision with root package name */
            public final /* synthetic */ N f1208b;

            {
                this.f1208b = this;
            }

            @Override // z.InterfaceC0769a
            public final void accept(Object obj) {
                switch (i7) {
                    case 0:
                        N n4 = this.f1208b;
                        if (n4.L()) {
                            n4.i(false);
                        }
                        break;
                    case 1:
                        Integer num = (Integer) obj;
                        N n5 = this.f1208b;
                        if (n5.L() && num.intValue() == 80) {
                            n5.m(false);
                            break;
                        }
                        break;
                    case 2:
                        q.k kVar = (q.k) obj;
                        N n6 = this.f1208b;
                        if (n6.L()) {
                            boolean z4 = kVar.f6216a;
                            n6.n(false);
                        }
                        break;
                    default:
                        q.x xVar = (q.x) obj;
                        N n7 = this.f1208b;
                        if (n7.L()) {
                            boolean z5 = xVar.f6240a;
                            n7.s(false);
                        }
                        break;
                }
            }
        };
        this.f1255t = new F(this);
        this.f1256u = -1;
        this.f1260z = new G(this);
        this.f1223A = new p1.d(13);
        this.f1227E = new ArrayDeque();
        this.f1236O = new F.b(this, 3);
    }

    public static HashSet E(C0090a c0090a) {
        HashSet hashSet = new HashSet();
        for (int i4 = 0; i4 < c0090a.f1304a.size(); i4++) {
            AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = ((V) c0090a.f1304a.get(i4)).f1292b;
            if (abstractComponentCallbacksC0109u != null && c0090a.f1309g) {
                hashSet.add(abstractComponentCallbacksC0109u);
            }
        }
        return hashSet;
    }

    public static boolean J(int i4) {
        return Log.isLoggable("FragmentManager", i4);
    }

    public static boolean K(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        abstractComponentCallbacksC0109u.getClass();
        boolean zK = false;
        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 : abstractComponentCallbacksC0109u.f1386A.f1239c.k()) {
            if (abstractComponentCallbacksC0109u2 != null) {
                zK = K(abstractComponentCallbacksC0109u2);
            }
            if (zK) {
                return true;
            }
        }
        return false;
    }

    public static boolean M(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        if (abstractComponentCallbacksC0109u == null) {
            return true;
        }
        if (abstractComponentCallbacksC0109u.f1394I) {
            return abstractComponentCallbacksC0109u.f1424y == null || M(abstractComponentCallbacksC0109u.f1387B);
        }
        return false;
    }

    public static boolean N(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        if (abstractComponentCallbacksC0109u == null) {
            return true;
        }
        N n4 = abstractComponentCallbacksC0109u.f1424y;
        return abstractComponentCallbacksC0109u.equals(n4.f1259y) && N(n4.f1258x);
    }

    public static void b0(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        if (J(2)) {
            Log.v("FragmentManager", "show: " + abstractComponentCallbacksC0109u);
        }
        if (abstractComponentCallbacksC0109u.f1391F) {
            abstractComponentCallbacksC0109u.f1391F = false;
            abstractComponentCallbacksC0109u.f1399O = !abstractComponentCallbacksC0109u.f1399O;
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:114:0x021e A[PHI: r14
      0x021e: PHI (r14v11 int) = (r14v10 int), (r14v12 int) binds: [B:107:0x020e, B:112:0x021a] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:66:0x016e  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void A(java.util.ArrayList r27, java.util.ArrayList r28, int r29, int r30) {
        /*
            Method dump skipped, instruction units count: 1358
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: O.N.A(java.util.ArrayList, java.util.ArrayList, int, int):void");
    }

    public final AbstractComponentCallbacksC0109u B(int i4) {
        C0053n c0053n = this.f1239c;
        ArrayList arrayList = (ArrayList) c0053n.f706b;
        for (int size = arrayList.size() - 1; size >= 0; size--) {
            AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = (AbstractComponentCallbacksC0109u) arrayList.get(size);
            if (abstractComponentCallbacksC0109u != null && abstractComponentCallbacksC0109u.f1388C == i4) {
                return abstractComponentCallbacksC0109u;
            }
        }
        for (U u4 : ((HashMap) c0053n.f707c).values()) {
            if (u4 != null) {
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = u4.f1289c;
                if (abstractComponentCallbacksC0109u2.f1388C == i4) {
                    return abstractComponentCallbacksC0109u2;
                }
            }
        }
        return null;
    }

    public final AbstractComponentCallbacksC0109u C(String str) {
        C0053n c0053n = this.f1239c;
        ArrayList arrayList = (ArrayList) c0053n.f706b;
        for (int size = arrayList.size() - 1; size >= 0; size--) {
            AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = (AbstractComponentCallbacksC0109u) arrayList.get(size);
            if (abstractComponentCallbacksC0109u != null && str.equals(abstractComponentCallbacksC0109u.f1390E)) {
                return abstractComponentCallbacksC0109u;
            }
        }
        for (U u4 : ((HashMap) c0053n.f707c).values()) {
            if (u4 != null) {
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = u4.f1289c;
                if (str.equals(abstractComponentCallbacksC0109u2.f1390E)) {
                    return abstractComponentCallbacksC0109u2;
                }
            }
        }
        return null;
    }

    public final void D() {
        for (C0102m c0102m : e()) {
            if (c0102m.e) {
                if (J(2)) {
                    Log.v("FragmentManager", "SpecialEffectsController: Forcing postponed operations");
                }
                c0102m.e = false;
                c0102m.c();
            }
        }
    }

    public final ViewGroup F(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        ViewGroup viewGroup = abstractComponentCallbacksC0109u.f1395K;
        if (viewGroup != null) {
            return viewGroup;
        }
        if (abstractComponentCallbacksC0109u.f1389D <= 0 || !this.f1257w.R()) {
            return null;
        }
        View viewQ = this.f1257w.Q(abstractComponentCallbacksC0109u.f1389D);
        if (viewQ instanceof ViewGroup) {
            return (ViewGroup) viewQ;
        }
        return null;
    }

    public final G G() {
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1258x;
        return abstractComponentCallbacksC0109u != null ? abstractComponentCallbacksC0109u.f1424y.G() : this.f1260z;
    }

    public final p1.d H() {
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1258x;
        return abstractComponentCallbacksC0109u != null ? abstractComponentCallbacksC0109u.f1424y.H() : this.f1223A;
    }

    public final void I(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        if (J(2)) {
            Log.v("FragmentManager", "hide: " + abstractComponentCallbacksC0109u);
        }
        if (abstractComponentCallbacksC0109u.f1391F) {
            return;
        }
        abstractComponentCallbacksC0109u.f1391F = true;
        abstractComponentCallbacksC0109u.f1399O = true ^ abstractComponentCallbacksC0109u.f1399O;
        a0(abstractComponentCallbacksC0109u);
    }

    public final boolean L() {
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1258x;
        if (abstractComponentCallbacksC0109u == null) {
            return true;
        }
        return abstractComponentCallbacksC0109u.f1425z != null && abstractComponentCallbacksC0109u.f1417q && abstractComponentCallbacksC0109u.o().L();
    }

    public final void O(int i4, boolean z4) {
        HashMap map;
        C0113y c0113y;
        if (this.v == null && i4 != -1) {
            throw new IllegalStateException("No activity");
        }
        if (z4 || i4 != this.f1256u) {
            this.f1256u = i4;
            C0053n c0053n = this.f1239c;
            Iterator it = ((ArrayList) c0053n.f706b).iterator();
            while (true) {
                boolean zHasNext = it.hasNext();
                map = (HashMap) c0053n.f707c;
                if (!zHasNext) {
                    break;
                }
                U u4 = (U) map.get(((AbstractComponentCallbacksC0109u) it.next()).e);
                if (u4 != null) {
                    u4.j();
                }
            }
            for (U u5 : map.values()) {
                if (u5 != null) {
                    u5.j();
                    AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = u5.f1289c;
                    if (abstractComponentCallbacksC0109u.f1418r && !abstractComponentCallbacksC0109u.s()) {
                        c0053n.q(u5);
                    }
                }
            }
            c0();
            if (this.f1228F && (c0113y = this.v) != null && this.f1256u == 7) {
                c0113y.f1435f.invalidateOptionsMenu();
                this.f1228F = false;
            }
        }
    }

    public final void P() {
        if (this.v == null) {
            return;
        }
        this.f1229G = false;
        this.f1230H = false;
        this.f1235N.f1273h = false;
        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u : this.f1239c.l()) {
            if (abstractComponentCallbacksC0109u != null) {
                abstractComponentCallbacksC0109u.f1386A.P();
            }
        }
    }

    public final boolean Q() {
        z(false);
        y(true);
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1259y;
        if (abstractComponentCallbacksC0109u != null && abstractComponentCallbacksC0109u.m().Q()) {
            return true;
        }
        boolean zR = R(this.f1232K, this.f1233L, -1, 0);
        if (zR) {
            this.f1238b = true;
            try {
                T(this.f1232K, this.f1233L);
            } finally {
                d();
            }
        }
        e0();
        if (this.J) {
            this.J = false;
            c0();
        }
        ((HashMap) this.f1239c.f707c).values().removeAll(Collections.singleton(null));
        return zR;
    }

    public final boolean R(ArrayList arrayList, ArrayList arrayList2, int i4, int i5) {
        boolean z4 = (i5 & 1) != 0;
        int size = -1;
        if (!this.f1240d.isEmpty()) {
            if (i4 < 0) {
                size = z4 ? 0 : this.f1240d.size() - 1;
            } else {
                int size2 = this.f1240d.size() - 1;
                while (size2 >= 0) {
                    C0090a c0090a = (C0090a) this.f1240d.get(size2);
                    if (i4 >= 0 && i4 == c0090a.f1320r) {
                        break;
                    }
                    size2--;
                }
                if (size2 < 0) {
                    size = size2;
                } else if (z4) {
                    size = size2;
                    while (size > 0) {
                        C0090a c0090a2 = (C0090a) this.f1240d.get(size - 1);
                        if (i4 < 0 || i4 != c0090a2.f1320r) {
                            break;
                        }
                        size--;
                    }
                } else if (size2 != this.f1240d.size() - 1) {
                    size = size2 + 1;
                }
            }
        }
        if (size < 0) {
            return false;
        }
        for (int size3 = this.f1240d.size() - 1; size3 >= size; size3--) {
            arrayList.add((C0090a) this.f1240d.remove(size3));
            arrayList2.add(Boolean.TRUE);
        }
        return true;
    }

    public final void S(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        if (J(2)) {
            Log.v("FragmentManager", "remove: " + abstractComponentCallbacksC0109u + " nesting=" + abstractComponentCallbacksC0109u.f1423x);
        }
        boolean zS = abstractComponentCallbacksC0109u.s();
        if (abstractComponentCallbacksC0109u.f1392G && zS) {
            return;
        }
        C0053n c0053n = this.f1239c;
        synchronized (((ArrayList) c0053n.f706b)) {
            ((ArrayList) c0053n.f706b).remove(abstractComponentCallbacksC0109u);
        }
        abstractComponentCallbacksC0109u.f1417q = false;
        if (K(abstractComponentCallbacksC0109u)) {
            this.f1228F = true;
        }
        abstractComponentCallbacksC0109u.f1418r = true;
        a0(abstractComponentCallbacksC0109u);
    }

    public final void T(ArrayList arrayList, ArrayList arrayList2) {
        if (arrayList.isEmpty()) {
            return;
        }
        if (arrayList.size() != arrayList2.size()) {
            throw new IllegalStateException("Internal error with the back stack records");
        }
        int size = arrayList.size();
        int i4 = 0;
        int i5 = 0;
        while (i4 < size) {
            if (!((C0090a) arrayList.get(i4)).f1317o) {
                if (i5 != i4) {
                    A(arrayList, arrayList2, i5, i4);
                }
                i5 = i4 + 1;
                if (((Boolean) arrayList2.get(i4)).booleanValue()) {
                    while (i5 < size && ((Boolean) arrayList2.get(i5)).booleanValue() && !((C0090a) arrayList.get(i5)).f1317o) {
                        i5++;
                    }
                }
                A(arrayList, arrayList2, i4, i5);
                i4 = i5 - 1;
            }
            i4++;
        }
        if (i5 != size) {
            A(arrayList, arrayList2, i5, size);
        }
    }

    public final void U(Bundle bundle) {
        int i4;
        D2.v vVar;
        int i5;
        U u4;
        Bundle bundle2;
        Bundle bundle3;
        for (String str : bundle.keySet()) {
            if (str.startsWith("result_") && (bundle3 = bundle.getBundle(str)) != null) {
                bundle3.setClassLoader(this.v.f1433c.getClassLoader());
                this.f1247l.put(str.substring(7), bundle3);
            }
        }
        HashMap map = new HashMap();
        for (String str2 : bundle.keySet()) {
            if (str2.startsWith("fragment_") && (bundle2 = bundle.getBundle(str2)) != null) {
                bundle2.setClassLoader(this.v.f1433c.getClassLoader());
                map.put(str2.substring(9), bundle2);
            }
        }
        C0053n c0053n = this.f1239c;
        HashMap map2 = (HashMap) c0053n.f708d;
        map2.clear();
        map2.putAll(map);
        P p4 = (P) bundle.getParcelable("state");
        if (p4 == null) {
            return;
        }
        HashMap map3 = (HashMap) c0053n.f707c;
        map3.clear();
        Iterator it = p4.f1262a.iterator();
        while (true) {
            boolean zHasNext = it.hasNext();
            i4 = 2;
            vVar = this.f1249n;
            if (!zHasNext) {
                break;
            }
            Bundle bundleZ = c0053n.z((String) it.next(), null);
            if (bundleZ != null) {
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = (AbstractComponentCallbacksC0109u) this.f1235N.f1269c.get(((T) bundleZ.getParcelable("state")).f1275b);
                if (abstractComponentCallbacksC0109u != null) {
                    if (J(2)) {
                        Log.v("FragmentManager", "restoreSaveState: re-attaching retained " + abstractComponentCallbacksC0109u);
                    }
                    u4 = new U(vVar, c0053n, abstractComponentCallbacksC0109u, bundleZ);
                } else {
                    u4 = new U(this.f1249n, this.f1239c, this.v.f1433c.getClassLoader(), G(), bundleZ);
                }
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = u4.f1289c;
                abstractComponentCallbacksC0109u2.f1409b = bundleZ;
                abstractComponentCallbacksC0109u2.f1424y = this;
                if (J(2)) {
                    Log.v("FragmentManager", "restoreSaveState: active (" + abstractComponentCallbacksC0109u2.e + "): " + abstractComponentCallbacksC0109u2);
                }
                u4.l(this.v.f1433c.getClassLoader());
                c0053n.o(u4);
                u4.e = this.f1256u;
            }
        }
        Q q4 = this.f1235N;
        q4.getClass();
        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u3 : new ArrayList(q4.f1269c.values())) {
            if (map3.get(abstractComponentCallbacksC0109u3.e) == null) {
                if (J(2)) {
                    Log.v("FragmentManager", "Discarding retained Fragment " + abstractComponentCallbacksC0109u3 + " that was not found in the set of active Fragments " + p4.f1262a);
                }
                this.f1235N.e(abstractComponentCallbacksC0109u3);
                abstractComponentCallbacksC0109u3.f1424y = this;
                U u5 = new U(vVar, c0053n, abstractComponentCallbacksC0109u3);
                u5.e = 1;
                u5.j();
                abstractComponentCallbacksC0109u3.f1418r = true;
                u5.j();
            }
        }
        ArrayList<String> arrayList = p4.f1263b;
        ((ArrayList) c0053n.f706b).clear();
        if (arrayList != null) {
            for (String str3 : arrayList) {
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109uH = c0053n.h(str3);
                if (abstractComponentCallbacksC0109uH == null) {
                    throw new IllegalStateException(com.google.crypto.tink.shaded.protobuf.S.g("No instantiated fragment for (", str3, ")"));
                }
                if (J(2)) {
                    Log.v("FragmentManager", "restoreSaveState: added (" + str3 + "): " + abstractComponentCallbacksC0109uH);
                }
                c0053n.a(abstractComponentCallbacksC0109uH);
            }
        }
        if (p4.f1264c != null) {
            this.f1240d = new ArrayList(p4.f1264c.length);
            int i6 = 0;
            while (true) {
                C0091b[] c0091bArr = p4.f1264c;
                if (i6 >= c0091bArr.length) {
                    break;
                }
                C0091b c0091b = c0091bArr[i6];
                c0091b.getClass();
                C0090a c0090a = new C0090a(this);
                int i7 = 0;
                int i8 = 0;
                while (true) {
                    int[] iArr = c0091b.f1322a;
                    if (i7 >= iArr.length) {
                        break;
                    }
                    V v = new V();
                    int i9 = i7 + 1;
                    int i10 = i4;
                    v.f1291a = iArr[i7];
                    if (J(i10)) {
                        Log.v("FragmentManager", "Instantiate " + c0090a + " op #" + i8 + " base fragment #" + iArr[i9]);
                    }
                    v.f1297h = EnumC0222h.values()[c0091b.f1324c[i8]];
                    v.f1298i = EnumC0222h.values()[c0091b.f1325d[i8]];
                    int i11 = i7 + 2;
                    v.f1293c = iArr[i9] != 0;
                    int i12 = iArr[i11];
                    v.f1294d = i12;
                    int i13 = iArr[i7 + 3];
                    v.e = i13;
                    int i14 = i7 + 5;
                    int i15 = iArr[i7 + 4];
                    v.f1295f = i15;
                    i7 += 6;
                    int i16 = iArr[i14];
                    v.f1296g = i16;
                    c0090a.f1305b = i12;
                    c0090a.f1306c = i13;
                    c0090a.f1307d = i15;
                    c0090a.e = i16;
                    c0090a.b(v);
                    i8++;
                    i4 = i10;
                }
                int i17 = i4;
                c0090a.f1308f = c0091b.e;
                c0090a.f1310h = c0091b.f1326f;
                c0090a.f1309g = true;
                c0090a.f1311i = c0091b.f1328n;
                c0090a.f1312j = c0091b.f1329o;
                c0090a.f1313k = c0091b.f1330p;
                c0090a.f1314l = c0091b.f1331q;
                c0090a.f1315m = c0091b.f1332r;
                c0090a.f1316n = c0091b.f1333s;
                c0090a.f1317o = c0091b.f1334t;
                c0090a.f1320r = c0091b.f1327m;
                int i18 = 0;
                while (true) {
                    ArrayList arrayList2 = c0091b.f1323b;
                    if (i18 >= arrayList2.size()) {
                        break;
                    }
                    String str4 = (String) arrayList2.get(i18);
                    if (str4 != null) {
                        ((V) c0090a.f1304a.get(i18)).f1292b = c0053n.h(str4);
                    }
                    i18++;
                }
                c0090a.c(1);
                if (J(i17)) {
                    StringBuilder sbI = com.google.crypto.tink.shaded.protobuf.S.i("restoreAllState: back stack #", i6, " (index ");
                    sbI.append(c0090a.f1320r);
                    sbI.append("): ");
                    sbI.append(c0090a);
                    Log.v("FragmentManager", sbI.toString());
                    PrintWriter printWriter = new PrintWriter(new X());
                    c0090a.f("  ", printWriter, false);
                    printWriter.close();
                }
                this.f1240d.add(c0090a);
                i6++;
                i4 = i17;
            }
            i5 = 0;
        } else {
            i5 = 0;
            this.f1240d = new ArrayList();
        }
        this.f1245j.set(p4.f1265d);
        String str5 = p4.e;
        if (str5 != null) {
            AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109uH2 = c0053n.h(str5);
            this.f1259y = abstractComponentCallbacksC0109uH2;
            r(abstractComponentCallbacksC0109uH2);
        }
        ArrayList arrayList3 = p4.f1266f;
        if (arrayList3 != null) {
            for (int i19 = i5; i19 < arrayList3.size(); i19++) {
                this.f1246k.put((String) arrayList3.get(i19), (C0092c) p4.f1267m.get(i19));
            }
        }
        this.f1227E = new ArrayDeque(p4.f1268n);
    }

    public final Bundle V() {
        int i4;
        ArrayList arrayList;
        C0091b[] c0091bArr;
        Bundle bundle;
        Bundle bundle2 = new Bundle();
        D();
        w();
        z(true);
        this.f1229G = true;
        this.f1235N.f1273h = true;
        C0053n c0053n = this.f1239c;
        c0053n.getClass();
        HashMap map = (HashMap) c0053n.f707c;
        ArrayList arrayList2 = new ArrayList(map.size());
        Iterator it = map.values().iterator();
        while (true) {
            if (!it.hasNext()) {
                break;
            }
            U u4 = (U) it.next();
            if (u4 != null) {
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = u4.f1289c;
                String str = abstractComponentCallbacksC0109u.e;
                Bundle bundle3 = new Bundle();
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = u4.f1289c;
                if (abstractComponentCallbacksC0109u2.f1408a == -1 && (bundle = abstractComponentCallbacksC0109u2.f1409b) != null) {
                    bundle3.putAll(bundle);
                }
                bundle3.putParcelable("state", new T(abstractComponentCallbacksC0109u2));
                if (abstractComponentCallbacksC0109u2.f1408a > -1) {
                    Bundle bundle4 = new Bundle();
                    abstractComponentCallbacksC0109u2.C(bundle4);
                    if (!bundle4.isEmpty()) {
                        bundle3.putBundle("savedInstanceState", bundle4);
                    }
                    u4.f1287a.u(abstractComponentCallbacksC0109u2, bundle4, false);
                    Bundle bundle5 = new Bundle();
                    abstractComponentCallbacksC0109u2.f1405U.d(bundle5);
                    if (!bundle5.isEmpty()) {
                        bundle3.putBundle("registryState", bundle5);
                    }
                    Bundle bundleV = abstractComponentCallbacksC0109u2.f1386A.V();
                    if (!bundleV.isEmpty()) {
                        bundle3.putBundle("childFragmentManager", bundleV);
                    }
                    SparseArray<? extends Parcelable> sparseArray = abstractComponentCallbacksC0109u2.f1410c;
                    if (sparseArray != null) {
                        bundle3.putSparseParcelableArray("viewState", sparseArray);
                    }
                    Bundle bundle6 = abstractComponentCallbacksC0109u2.f1411d;
                    if (bundle6 != null) {
                        bundle3.putBundle("viewRegistryState", bundle6);
                    }
                }
                Bundle bundle7 = abstractComponentCallbacksC0109u2.f1412f;
                if (bundle7 != null) {
                    bundle3.putBundle("arguments", bundle7);
                }
                c0053n.z(str, bundle3);
                arrayList2.add(abstractComponentCallbacksC0109u.e);
                if (J(2)) {
                    Log.v("FragmentManager", "Saved state of " + abstractComponentCallbacksC0109u + ": " + abstractComponentCallbacksC0109u.f1409b);
                }
            }
        }
        HashMap map2 = (HashMap) this.f1239c.f708d;
        if (!map2.isEmpty()) {
            C0053n c0053n2 = this.f1239c;
            synchronized (((ArrayList) c0053n2.f706b)) {
                try {
                    if (((ArrayList) c0053n2.f706b).isEmpty()) {
                        arrayList = null;
                    } else {
                        arrayList = new ArrayList(((ArrayList) c0053n2.f706b).size());
                        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u3 : (ArrayList) c0053n2.f706b) {
                            arrayList.add(abstractComponentCallbacksC0109u3.e);
                            if (J(2)) {
                                Log.v("FragmentManager", "saveAllState: adding fragment (" + abstractComponentCallbacksC0109u3.e + "): " + abstractComponentCallbacksC0109u3);
                            }
                        }
                    }
                } finally {
                }
            }
            int size = this.f1240d.size();
            if (size > 0) {
                c0091bArr = new C0091b[size];
                for (i4 = 0; i4 < size; i4++) {
                    c0091bArr[i4] = new C0091b((C0090a) this.f1240d.get(i4));
                    if (J(2)) {
                        StringBuilder sbI = com.google.crypto.tink.shaded.protobuf.S.i("saveAllState: adding back stack #", i4, ": ");
                        sbI.append(this.f1240d.get(i4));
                        Log.v("FragmentManager", sbI.toString());
                    }
                }
            } else {
                c0091bArr = null;
            }
            P p4 = new P();
            p4.e = null;
            ArrayList arrayList3 = new ArrayList();
            p4.f1266f = arrayList3;
            ArrayList arrayList4 = new ArrayList();
            p4.f1267m = arrayList4;
            p4.f1262a = arrayList2;
            p4.f1263b = arrayList;
            p4.f1264c = c0091bArr;
            p4.f1265d = this.f1245j.get();
            AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u4 = this.f1259y;
            if (abstractComponentCallbacksC0109u4 != null) {
                p4.e = abstractComponentCallbacksC0109u4.e;
            }
            arrayList3.addAll(this.f1246k.keySet());
            arrayList4.addAll(this.f1246k.values());
            p4.f1268n = new ArrayList(this.f1227E);
            bundle2.putParcelable("state", p4);
            for (String str2 : this.f1247l.keySet()) {
                bundle2.putBundle(B1.a.m("result_", str2), (Bundle) this.f1247l.get(str2));
            }
            for (String str3 : map2.keySet()) {
                bundle2.putBundle(B1.a.m("fragment_", str3), (Bundle) map2.get(str3));
            }
        } else if (J(2)) {
            Log.v("FragmentManager", "saveAllState: no fragments!");
            return bundle2;
        }
        return bundle2;
    }

    public final void W() {
        synchronized (this.f1237a) {
            try {
                if (this.f1237a.size() == 1) {
                    this.v.f1434d.removeCallbacks(this.f1236O);
                    this.v.f1434d.post(this.f1236O);
                    e0();
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final void X(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        ViewGroup viewGroupF = F(abstractComponentCallbacksC0109u);
        if (viewGroupF == null || !(viewGroupF instanceof B)) {
            return;
        }
        ((B) viewGroupF).setDrawDisappearingViewsLast(!z4);
    }

    public final void Y(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, EnumC0222h enumC0222h) {
        if (abstractComponentCallbacksC0109u.equals(this.f1239c.h(abstractComponentCallbacksC0109u.e)) && (abstractComponentCallbacksC0109u.f1425z == null || abstractComponentCallbacksC0109u.f1424y == this)) {
            abstractComponentCallbacksC0109u.f1402R = enumC0222h;
            return;
        }
        throw new IllegalArgumentException("Fragment " + abstractComponentCallbacksC0109u + " is not an active fragment of FragmentManager " + this);
    }

    public final void Z(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        if (abstractComponentCallbacksC0109u != null) {
            if (!abstractComponentCallbacksC0109u.equals(this.f1239c.h(abstractComponentCallbacksC0109u.e)) || (abstractComponentCallbacksC0109u.f1425z != null && abstractComponentCallbacksC0109u.f1424y != this)) {
                throw new IllegalArgumentException("Fragment " + abstractComponentCallbacksC0109u + " is not an active fragment of FragmentManager " + this);
            }
        }
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = this.f1259y;
        this.f1259y = abstractComponentCallbacksC0109u;
        r(abstractComponentCallbacksC0109u2);
        r(this.f1259y);
    }

    public final U a(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        String str = abstractComponentCallbacksC0109u.f1401Q;
        if (str != null) {
            P.d.c(abstractComponentCallbacksC0109u, str);
        }
        if (J(2)) {
            Log.v("FragmentManager", "add: " + abstractComponentCallbacksC0109u);
        }
        U uG = g(abstractComponentCallbacksC0109u);
        abstractComponentCallbacksC0109u.f1424y = this;
        C0053n c0053n = this.f1239c;
        c0053n.o(uG);
        if (!abstractComponentCallbacksC0109u.f1392G) {
            c0053n.a(abstractComponentCallbacksC0109u);
            abstractComponentCallbacksC0109u.f1418r = false;
            abstractComponentCallbacksC0109u.f1399O = false;
            if (K(abstractComponentCallbacksC0109u)) {
                this.f1228F = true;
            }
        }
        return uG;
    }

    public final void a0(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        ViewGroup viewGroupF = F(abstractComponentCallbacksC0109u);
        if (viewGroupF != null) {
            C0108t c0108t = abstractComponentCallbacksC0109u.f1398N;
            if ((c0108t == null ? 0 : c0108t.e) + (c0108t == null ? 0 : c0108t.f1379d) + (c0108t == null ? 0 : c0108t.f1378c) + (c0108t == null ? 0 : c0108t.f1377b) > 0) {
                if (viewGroupF.getTag(R.id.visible_removing_fragment_view_tag) == null) {
                    viewGroupF.setTag(R.id.visible_removing_fragment_view_tag, abstractComponentCallbacksC0109u);
                }
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = (AbstractComponentCallbacksC0109u) viewGroupF.getTag(R.id.visible_removing_fragment_view_tag);
                C0108t c0108t2 = abstractComponentCallbacksC0109u.f1398N;
                boolean z4 = c0108t2 != null ? c0108t2.f1376a : false;
                if (abstractComponentCallbacksC0109u2.f1398N == null) {
                    return;
                }
                abstractComponentCallbacksC0109u2.l().f1376a = z4;
            }
        }
    }

    public final void b(C0113y c0113y, AbstractC0184a abstractC0184a, AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        Q q4;
        if (this.v != null) {
            throw new IllegalStateException("Already attached");
        }
        this.v = c0113y;
        this.f1257w = abstractC0184a;
        this.f1258x = abstractComponentCallbacksC0109u;
        CopyOnWriteArrayList copyOnWriteArrayList = this.f1250o;
        if (abstractComponentCallbacksC0109u != null) {
            copyOnWriteArrayList.add(new H(abstractComponentCallbacksC0109u));
        } else if (c0113y != null) {
            copyOnWriteArrayList.add(c0113y);
        }
        if (this.f1258x != null) {
            e0();
        }
        if (c0113y != null) {
            b.u uVarB = c0113y.f1435f.b();
            this.f1242g = uVarB;
            androidx.lifecycle.n nVar = abstractComponentCallbacksC0109u != null ? abstractComponentCallbacksC0109u : c0113y;
            uVarB.getClass();
            E e = this.f1244i;
            J3.i.e(e, "onBackPressedCallback");
            androidx.lifecycle.p pVarI = nVar.i();
            if (pVarI.f3077c != EnumC0222h.f3067a) {
                e.f1210b.add(new C0241r(uVarB, pVarI, e));
                uVarB.c();
                e.f1211c = new b.t(0, uVarB, b.u.class, "updateEnabledCallbacks", "updateEnabledCallbacks()V", 0, 0);
            }
        }
        if (abstractComponentCallbacksC0109u != null) {
            Q q5 = abstractComponentCallbacksC0109u.f1424y.f1235N;
            HashMap map = q5.f1270d;
            Q q6 = (Q) map.get(abstractComponentCallbacksC0109u.e);
            if (q6 == null) {
                q6 = new Q(q5.f1271f);
                map.put(abstractComponentCallbacksC0109u.e, q6);
            }
            this.f1235N = q6;
        } else if (c0113y != null) {
            androidx.lifecycle.H hG = c0113y.f1435f.g();
            J3.i.e(hG, "store");
            Q.a aVar = Q.a.f1508b;
            J3.i.e(aVar, "defaultCreationExtras");
            String canonicalName = Q.class.getCanonicalName();
            if (canonicalName == null) {
                throw new IllegalArgumentException("Local and anonymous classes can not be ViewModels");
            }
            String strConcat = "androidx.lifecycle.ViewModelProvider.DefaultKey:".concat(canonicalName);
            J3.i.e(strConcat, "key");
            LinkedHashMap linkedHashMap = hG.f3062a;
            androidx.lifecycle.F f4 = (androidx.lifecycle.F) linkedHashMap.get(strConcat);
            if (Q.class.isInstance(f4)) {
                J3.i.c(f4, "null cannot be cast to non-null type T of androidx.lifecycle.ViewModelProvider.get");
            } else {
                ((LinkedHashMap) new Q.c(aVar).f1509a).put(androidx.lifecycle.G.f3061b, strConcat);
                try {
                    q4 = new Q(true);
                } catch (AbstractMethodError unused) {
                    q4 = new Q(true);
                }
                f4 = q4;
                androidx.lifecycle.F f5 = (androidx.lifecycle.F) linkedHashMap.put(strConcat, f4);
                if (f5 != null) {
                    f5.a();
                }
            }
            this.f1235N = (Q) f4;
        } else {
            this.f1235N = new Q(false);
        }
        Q q7 = this.f1235N;
        q7.f1273h = this.f1229G || this.f1230H;
        this.f1239c.e = q7;
        C0113y c0113y2 = this.v;
        if (c0113y2 != null && abstractComponentCallbacksC0109u == null) {
            Y.e eVarC = c0113y2.c();
            eVarC.b("android:support:fragments", new C0110v(this, 2));
            Bundle bundleA = eVarC.a("android:support:fragments");
            if (bundleA != null) {
                U(bundleA);
            }
        }
        C0113y c0113y3 = this.v;
        if (c0113y3 != null) {
            AbstractActivityC0114z abstractActivityC0114z = c0113y3.f1435f;
            String strM = B1.a.m("FragmentManager:", abstractComponentCallbacksC0109u != null ? com.google.crypto.tink.shaded.protobuf.S.h(new StringBuilder(), abstractComponentCallbacksC0109u.e, ":") : "");
            String strF = com.google.crypto.tink.shaded.protobuf.S.f(strM, "StartActivityForResult");
            I i4 = new I(2);
            C0779j c0779j = new C0779j(this, 15);
            C0229f c0229f = abstractActivityC0114z.f3236p;
            this.f1224B = c0229f.c(strF, i4, c0779j);
            this.f1225C = c0229f.c(com.google.crypto.tink.shaded.protobuf.S.f(strM, "StartIntentSenderForResult"), new I(0), new B.k(this, 14));
            this.f1226D = c0229f.c(com.google.crypto.tink.shaded.protobuf.S.f(strM, "RequestPermissions"), new I(1), new C0690c(this, 15));
        }
        C0113y c0113y4 = this.v;
        if (c0113y4 != null) {
            c0113y4.d(this.f1251p);
        }
        C0113y c0113y5 = this.v;
        if (c0113y5 != null) {
            c0113y5.f1435f.f3238r.add(this.f1252q);
        }
        C0113y c0113y6 = this.v;
        if (c0113y6 != null) {
            c0113y6.f1435f.f3240t.add(this.f1253r);
        }
        C0113y c0113y7 = this.v;
        if (c0113y7 != null) {
            c0113y7.f1435f.f3241u.add(this.f1254s);
        }
        C0113y c0113y8 = this.v;
        if (c0113y8 == null || abstractComponentCallbacksC0109u != null) {
            return;
        }
        AbstractActivityC0114z abstractActivityC0114z2 = c0113y8.f1435f;
        F f6 = this.f1255t;
        C0747k c0747k = abstractActivityC0114z2.f3230c;
        ((CopyOnWriteArrayList) c0747k.f6832c).add(f6);
        ((F1.a) c0747k.f6831b).run();
    }

    public final void c(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        if (J(2)) {
            Log.v("FragmentManager", "attach: " + abstractComponentCallbacksC0109u);
        }
        if (abstractComponentCallbacksC0109u.f1392G) {
            abstractComponentCallbacksC0109u.f1392G = false;
            if (abstractComponentCallbacksC0109u.f1417q) {
                return;
            }
            this.f1239c.a(abstractComponentCallbacksC0109u);
            if (J(2)) {
                Log.v("FragmentManager", "add from attach: " + abstractComponentCallbacksC0109u);
            }
            if (K(abstractComponentCallbacksC0109u)) {
                this.f1228F = true;
            }
        }
    }

    public final void c0() {
        for (U u4 : this.f1239c.j()) {
            AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = u4.f1289c;
            if (abstractComponentCallbacksC0109u.f1396L) {
                if (this.f1238b) {
                    this.J = true;
                } else {
                    abstractComponentCallbacksC0109u.f1396L = false;
                    u4.j();
                }
            }
        }
    }

    public final void d() {
        this.f1238b = false;
        this.f1233L.clear();
        this.f1232K.clear();
    }

    public final void d0(IllegalStateException illegalStateException) {
        Log.e("FragmentManager", illegalStateException.getMessage());
        Log.e("FragmentManager", "Activity state:");
        PrintWriter printWriter = new PrintWriter(new X());
        C0113y c0113y = this.v;
        if (c0113y == null) {
            try {
                v("  ", null, printWriter, new String[0]);
                throw illegalStateException;
            } catch (Exception e) {
                Log.e("FragmentManager", "Failed dumping state", e);
                throw illegalStateException;
            }
        }
        try {
            c0113y.f1435f.dump("  ", null, printWriter, new String[0]);
            throw illegalStateException;
        } catch (Exception e4) {
            Log.e("FragmentManager", "Failed dumping state", e4);
            throw illegalStateException;
        }
    }

    public final HashSet e() {
        C0102m c0102m;
        HashSet hashSet = new HashSet();
        Iterator it = this.f1239c.j().iterator();
        while (it.hasNext()) {
            ViewGroup viewGroup = ((U) it.next()).f1289c.f1395K;
            if (viewGroup != null) {
                J3.i.e(H(), "factory");
                Object tag = viewGroup.getTag(R.id.special_effects_controller_view_tag);
                if (tag instanceof C0102m) {
                    c0102m = (C0102m) tag;
                } else {
                    c0102m = new C0102m(viewGroup);
                    viewGroup.setTag(R.id.special_effects_controller_view_tag, c0102m);
                }
                hashSet.add(c0102m);
            }
        }
        return hashSet;
    }

    /* JADX WARN: Type inference failed for: r0v7, types: [I3.a, J3.h] */
    /* JADX WARN: Type inference failed for: r2v6, types: [I3.a, J3.h] */
    public final void e0() {
        synchronized (this.f1237a) {
            try {
                if (!this.f1237a.isEmpty()) {
                    E e = this.f1244i;
                    e.f1209a = true;
                    ?? r22 = e.f1211c;
                    if (r22 != 0) {
                        r22.a();
                    }
                    if (J(3)) {
                        Log.d("FragmentManager", "FragmentManager " + this + " enabling OnBackPressedCallback, caused by non-empty pending actions");
                    }
                    return;
                }
                boolean z4 = this.f1240d.size() + (this.f1243h != null ? 1 : 0) > 0 && N(this.f1258x);
                if (J(3)) {
                    Log.d("FragmentManager", "OnBackPressedCallback for FragmentManager " + this + " enabled state is " + z4);
                }
                E e4 = this.f1244i;
                e4.f1209a = z4;
                ?? r02 = e4.f1211c;
                if (r02 != 0) {
                    r02.a();
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final HashSet f(ArrayList arrayList, int i4, int i5) {
        ViewGroup viewGroup;
        HashSet hashSet = new HashSet();
        while (i4 < i5) {
            Iterator it = ((C0090a) arrayList.get(i4)).f1304a.iterator();
            while (it.hasNext()) {
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = ((V) it.next()).f1292b;
                if (abstractComponentCallbacksC0109u != null && (viewGroup = abstractComponentCallbacksC0109u.f1395K) != null) {
                    hashSet.add(C0102m.e(viewGroup, this));
                }
            }
            i4++;
        }
        return hashSet;
    }

    public final U g(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        String str = abstractComponentCallbacksC0109u.e;
        C0053n c0053n = this.f1239c;
        U u4 = (U) ((HashMap) c0053n.f707c).get(str);
        if (u4 != null) {
            return u4;
        }
        U u5 = new U(this.f1249n, c0053n, abstractComponentCallbacksC0109u);
        u5.l(this.v.f1433c.getClassLoader());
        u5.e = this.f1256u;
        return u5;
    }

    public final void h(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        if (J(2)) {
            Log.v("FragmentManager", "detach: " + abstractComponentCallbacksC0109u);
        }
        if (abstractComponentCallbacksC0109u.f1392G) {
            return;
        }
        abstractComponentCallbacksC0109u.f1392G = true;
        if (abstractComponentCallbacksC0109u.f1417q) {
            if (J(2)) {
                Log.v("FragmentManager", "remove from detach: " + abstractComponentCallbacksC0109u);
            }
            C0053n c0053n = this.f1239c;
            synchronized (((ArrayList) c0053n.f706b)) {
                ((ArrayList) c0053n.f706b).remove(abstractComponentCallbacksC0109u);
            }
            abstractComponentCallbacksC0109u.f1417q = false;
            if (K(abstractComponentCallbacksC0109u)) {
                this.f1228F = true;
            }
            a0(abstractComponentCallbacksC0109u);
        }
    }

    public final void i(boolean z4) {
        if (z4 && this.v != null) {
            d0(new IllegalStateException("Do not call dispatchConfigurationChanged() on host. Host implements OnConfigurationChangedProvider and automatically dispatches configuration changes to fragments."));
            throw null;
        }
        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u : this.f1239c.l()) {
            if (abstractComponentCallbacksC0109u != null) {
                abstractComponentCallbacksC0109u.J = true;
                if (z4) {
                    abstractComponentCallbacksC0109u.f1386A.i(true);
                }
            }
        }
    }

    public final boolean j() {
        if (this.f1256u < 1) {
            return false;
        }
        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u : this.f1239c.l()) {
            if (abstractComponentCallbacksC0109u != null) {
                if (!abstractComponentCallbacksC0109u.f1391F ? abstractComponentCallbacksC0109u.f1386A.j() : false) {
                    return true;
                }
            }
        }
        return false;
    }

    public final boolean k() {
        if (this.f1256u < 1) {
            return false;
        }
        ArrayList arrayList = null;
        boolean z4 = false;
        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u : this.f1239c.l()) {
            if (abstractComponentCallbacksC0109u != null && M(abstractComponentCallbacksC0109u)) {
                if (!abstractComponentCallbacksC0109u.f1391F ? abstractComponentCallbacksC0109u.f1386A.k() : false) {
                    if (arrayList == null) {
                        arrayList = new ArrayList();
                    }
                    arrayList.add(abstractComponentCallbacksC0109u);
                    z4 = true;
                }
            }
        }
        if (this.e != null) {
            for (int i4 = 0; i4 < this.e.size(); i4++) {
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = (AbstractComponentCallbacksC0109u) this.e.get(i4);
                if (arrayList == null || !arrayList.contains(abstractComponentCallbacksC0109u2)) {
                    abstractComponentCallbacksC0109u2.getClass();
                }
            }
        }
        this.e = arrayList;
        return z4;
    }

    public final void l() {
        boolean zIsChangingConfigurations = true;
        this.f1231I = true;
        z(true);
        w();
        C0113y c0113y = this.v;
        C0053n c0053n = this.f1239c;
        if (c0113y != null) {
            zIsChangingConfigurations = ((Q) c0053n.e).f1272g;
        } else {
            AbstractActivityC0114z abstractActivityC0114z = c0113y.f1433c;
            if (abstractActivityC0114z != null) {
                zIsChangingConfigurations = true ^ abstractActivityC0114z.isChangingConfigurations();
            }
        }
        if (zIsChangingConfigurations) {
            Iterator it = this.f1246k.values().iterator();
            while (it.hasNext()) {
                Iterator it2 = ((C0092c) it.next()).f1335a.iterator();
                while (it2.hasNext()) {
                    ((Q) c0053n.e).c((String) it2.next(), false);
                }
            }
        }
        u(-1);
        C0113y c0113y2 = this.v;
        if (c0113y2 != null) {
            AbstractActivityC0114z abstractActivityC0114z2 = c0113y2.f1435f;
            abstractActivityC0114z2.f3238r.remove(this.f1252q);
        }
        C0113y c0113y3 = this.v;
        if (c0113y3 != null) {
            c0113y3.e(this.f1251p);
        }
        C0113y c0113y4 = this.v;
        if (c0113y4 != null) {
            AbstractActivityC0114z abstractActivityC0114z3 = c0113y4.f1435f;
            abstractActivityC0114z3.f3240t.remove(this.f1253r);
        }
        C0113y c0113y5 = this.v;
        if (c0113y5 != null) {
            AbstractActivityC0114z abstractActivityC0114z4 = c0113y5.f1435f;
            abstractActivityC0114z4.f3241u.remove(this.f1254s);
        }
        C0113y c0113y6 = this.v;
        if (c0113y6 != null && this.f1258x == null) {
            AbstractActivityC0114z abstractActivityC0114z5 = c0113y6.f1435f;
            F f4 = this.f1255t;
            C0747k c0747k = abstractActivityC0114z5.f3230c;
            ((CopyOnWriteArrayList) c0747k.f6832c).remove(f4);
            if (((HashMap) c0747k.f6833d).remove(f4) != null) {
                throw new ClassCastException();
            }
            ((F1.a) c0747k.f6831b).run();
        }
        this.v = null;
        this.f1257w = null;
        this.f1258x = null;
        if (this.f1242g != null) {
            Iterator it3 = this.f1244i.f1210b.iterator();
            while (it3.hasNext()) {
                ((InterfaceC0226c) it3.next()).cancel();
            }
            this.f1242g = null;
        }
        C0747k c0747k2 = this.f1224B;
        if (c0747k2 != null) {
            c0747k2.a0();
            this.f1225C.a0();
            this.f1226D.a0();
        }
    }

    public final void m(boolean z4) {
        if (z4 && this.v != null) {
            d0(new IllegalStateException("Do not call dispatchLowMemory() on host. Host implements OnTrimMemoryProvider and automatically dispatches low memory callbacks to fragments."));
            throw null;
        }
        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u : this.f1239c.l()) {
            if (abstractComponentCallbacksC0109u != null) {
                abstractComponentCallbacksC0109u.J = true;
                if (z4) {
                    abstractComponentCallbacksC0109u.f1386A.m(true);
                }
            }
        }
    }

    public final void n(boolean z4) {
        if (z4 && this.v != null) {
            d0(new IllegalStateException("Do not call dispatchMultiWindowModeChanged() on host. Host implements OnMultiWindowModeChangedProvider and automatically dispatches multi-window mode changes to fragments."));
            throw null;
        }
        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u : this.f1239c.l()) {
            if (abstractComponentCallbacksC0109u != null && z4) {
                abstractComponentCallbacksC0109u.f1386A.n(true);
            }
        }
    }

    public final void o() {
        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u : this.f1239c.k()) {
            if (abstractComponentCallbacksC0109u != null) {
                abstractComponentCallbacksC0109u.r();
                abstractComponentCallbacksC0109u.f1386A.o();
            }
        }
    }

    public final boolean p() {
        if (this.f1256u >= 1) {
            for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u : this.f1239c.l()) {
                if (abstractComponentCallbacksC0109u != null) {
                    if (!abstractComponentCallbacksC0109u.f1391F ? abstractComponentCallbacksC0109u.f1386A.p() : false) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    public final void q() {
        if (this.f1256u < 1) {
            return;
        }
        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u : this.f1239c.l()) {
            if (abstractComponentCallbacksC0109u != null && !abstractComponentCallbacksC0109u.f1391F) {
                abstractComponentCallbacksC0109u.f1386A.q();
            }
        }
    }

    public final void r(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        if (abstractComponentCallbacksC0109u != null) {
            if (abstractComponentCallbacksC0109u.equals(this.f1239c.h(abstractComponentCallbacksC0109u.e))) {
                abstractComponentCallbacksC0109u.f1424y.getClass();
                boolean zN = N(abstractComponentCallbacksC0109u);
                Boolean bool = abstractComponentCallbacksC0109u.f1416p;
                if (bool == null || bool.booleanValue() != zN) {
                    abstractComponentCallbacksC0109u.f1416p = Boolean.valueOf(zN);
                    N n4 = abstractComponentCallbacksC0109u.f1386A;
                    n4.e0();
                    n4.r(n4.f1259y);
                }
            }
        }
    }

    public final void s(boolean z4) {
        if (z4 && this.v != null) {
            d0(new IllegalStateException("Do not call dispatchPictureInPictureModeChanged() on host. Host implements OnPictureInPictureModeChangedProvider and automatically dispatches picture-in-picture mode changes to fragments."));
            throw null;
        }
        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u : this.f1239c.l()) {
            if (abstractComponentCallbacksC0109u != null && z4) {
                abstractComponentCallbacksC0109u.f1386A.s(true);
            }
        }
    }

    public final boolean t() {
        if (this.f1256u < 1) {
            return false;
        }
        boolean z4 = false;
        for (AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u : this.f1239c.l()) {
            if (abstractComponentCallbacksC0109u != null && M(abstractComponentCallbacksC0109u)) {
                if (!abstractComponentCallbacksC0109u.f1391F ? abstractComponentCallbacksC0109u.f1386A.t() : false) {
                    z4 = true;
                }
            }
        }
        return z4;
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder(128);
        sb.append("FragmentManager{");
        sb.append(Integer.toHexString(System.identityHashCode(this)));
        sb.append(" in ");
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1258x;
        if (abstractComponentCallbacksC0109u != null) {
            sb.append(abstractComponentCallbacksC0109u.getClass().getSimpleName());
            sb.append("{");
            sb.append(Integer.toHexString(System.identityHashCode(this.f1258x)));
            sb.append("}");
        } else {
            C0113y c0113y = this.v;
            if (c0113y != null) {
                sb.append(c0113y.getClass().getSimpleName());
                sb.append("{");
                sb.append(Integer.toHexString(System.identityHashCode(this.v)));
                sb.append("}");
            } else {
                sb.append("null");
            }
        }
        sb.append("}}");
        return sb.toString();
    }

    public final void u(int i4) {
        try {
            this.f1238b = true;
            for (U u4 : ((HashMap) this.f1239c.f707c).values()) {
                if (u4 != null) {
                    u4.e = i4;
                }
            }
            O(i4, false);
            Iterator it = e().iterator();
            while (it.hasNext()) {
                ((C0102m) it.next()).d();
            }
            this.f1238b = false;
            z(true);
        } catch (Throwable th) {
            this.f1238b = false;
            throw th;
        }
    }

    public final void v(String str, FileDescriptor fileDescriptor, PrintWriter printWriter, String[] strArr) {
        int size;
        String strF = com.google.crypto.tink.shaded.protobuf.S.f(str, "    ");
        C0053n c0053n = this.f1239c;
        c0053n.getClass();
        String str2 = str + "    ";
        HashMap map = (HashMap) c0053n.f707c;
        if (!map.isEmpty()) {
            printWriter.print(str);
            printWriter.println("Active Fragments:");
            for (U u4 : map.values()) {
                printWriter.print(str);
                if (u4 != null) {
                    AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = u4.f1289c;
                    printWriter.println(abstractComponentCallbacksC0109u);
                    abstractComponentCallbacksC0109u.k(str2, fileDescriptor, printWriter, strArr);
                } else {
                    printWriter.println("null");
                }
            }
        }
        ArrayList arrayList = (ArrayList) c0053n.f706b;
        int size2 = arrayList.size();
        if (size2 > 0) {
            printWriter.print(str);
            printWriter.println("Added Fragments:");
            for (int i4 = 0; i4 < size2; i4++) {
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = (AbstractComponentCallbacksC0109u) arrayList.get(i4);
                printWriter.print(str);
                printWriter.print("  #");
                printWriter.print(i4);
                printWriter.print(": ");
                printWriter.println(abstractComponentCallbacksC0109u2.toString());
            }
        }
        ArrayList arrayList2 = this.e;
        if (arrayList2 != null && (size = arrayList2.size()) > 0) {
            printWriter.print(str);
            printWriter.println("Fragments Created Menus:");
            for (int i5 = 0; i5 < size; i5++) {
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u3 = (AbstractComponentCallbacksC0109u) this.e.get(i5);
                printWriter.print(str);
                printWriter.print("  #");
                printWriter.print(i5);
                printWriter.print(": ");
                printWriter.println(abstractComponentCallbacksC0109u3.toString());
            }
        }
        int size3 = this.f1240d.size();
        if (size3 > 0) {
            printWriter.print(str);
            printWriter.println("Back Stack:");
            for (int i6 = 0; i6 < size3; i6++) {
                C0090a c0090a = (C0090a) this.f1240d.get(i6);
                printWriter.print(str);
                printWriter.print("  #");
                printWriter.print(i6);
                printWriter.print(": ");
                printWriter.println(c0090a.toString());
                c0090a.f(strF, printWriter, true);
            }
        }
        printWriter.print(str);
        printWriter.println("Back Stack Index: " + this.f1245j.get());
        synchronized (this.f1237a) {
            try {
                int size4 = this.f1237a.size();
                if (size4 > 0) {
                    printWriter.print(str);
                    printWriter.println("Pending Actions:");
                    for (int i7 = 0; i7 < size4; i7++) {
                        Object obj = (K) this.f1237a.get(i7);
                        printWriter.print(str);
                        printWriter.print("  #");
                        printWriter.print(i7);
                        printWriter.print(": ");
                        printWriter.println(obj);
                    }
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        printWriter.print(str);
        printWriter.println("FragmentManager misc state:");
        printWriter.print(str);
        printWriter.print("  mHost=");
        printWriter.println(this.v);
        printWriter.print(str);
        printWriter.print("  mContainer=");
        printWriter.println(this.f1257w);
        if (this.f1258x != null) {
            printWriter.print(str);
            printWriter.print("  mParent=");
            printWriter.println(this.f1258x);
        }
        printWriter.print(str);
        printWriter.print("  mCurState=");
        printWriter.print(this.f1256u);
        printWriter.print(" mStateSaved=");
        printWriter.print(this.f1229G);
        printWriter.print(" mStopped=");
        printWriter.print(this.f1230H);
        printWriter.print(" mDestroyed=");
        printWriter.println(this.f1231I);
        if (this.f1228F) {
            printWriter.print(str);
            printWriter.print("  mNeedMenuInvalidate=");
            printWriter.println(this.f1228F);
        }
    }

    public final void w() {
        Iterator it = e().iterator();
        while (it.hasNext()) {
            ((C0102m) it.next()).d();
        }
    }

    public final void x(K k4, boolean z4) {
        if (!z4) {
            if (this.v == null) {
                if (!this.f1231I) {
                    throw new IllegalStateException("FragmentManager has not been attached to a host.");
                }
                throw new IllegalStateException("FragmentManager has been destroyed");
            }
            if (this.f1229G || this.f1230H) {
                throw new IllegalStateException("Can not perform this action after onSaveInstanceState");
            }
        }
        synchronized (this.f1237a) {
            try {
                if (this.v == null) {
                    if (!z4) {
                        throw new IllegalStateException("Activity has been destroyed");
                    }
                } else {
                    this.f1237a.add(k4);
                    W();
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final void y(boolean z4) {
        if (this.f1238b) {
            throw new IllegalStateException("FragmentManager is already executing transactions");
        }
        if (this.v == null) {
            if (!this.f1231I) {
                throw new IllegalStateException("FragmentManager has not been attached to a host.");
            }
            throw new IllegalStateException("FragmentManager has been destroyed");
        }
        if (Looper.myLooper() != this.v.f1434d.getLooper()) {
            throw new IllegalStateException("Must be called from main thread of fragment host");
        }
        if (!z4 && (this.f1229G || this.f1230H)) {
            throw new IllegalStateException("Can not perform this action after onSaveInstanceState");
        }
        if (this.f1232K == null) {
            this.f1232K = new ArrayList();
            this.f1233L = new ArrayList();
        }
    }

    public final boolean z(boolean z4) {
        boolean zA;
        y(z4);
        boolean z5 = false;
        while (true) {
            ArrayList arrayList = this.f1232K;
            ArrayList arrayList2 = this.f1233L;
            synchronized (this.f1237a) {
                if (this.f1237a.isEmpty()) {
                    zA = false;
                } else {
                    try {
                        int size = this.f1237a.size();
                        zA = false;
                        for (int i4 = 0; i4 < size; i4++) {
                            zA |= ((K) this.f1237a.get(i4)).a(arrayList, arrayList2);
                        }
                    } finally {
                    }
                }
            }
            if (!zA) {
                break;
            }
            z5 = true;
            this.f1238b = true;
            try {
                T(this.f1232K, this.f1233L);
            } finally {
                d();
            }
        }
        e0();
        if (this.J) {
            this.J = false;
            c0();
        }
        ((HashMap) this.f1239c.f707c).values().removeAll(Collections.singleton(null));
        return z5;
    }
}
