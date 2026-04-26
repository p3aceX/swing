package D2;

import I.C0053n;
import Q3.C0120b0;
import Q3.InterfaceC0132h0;
import Q3.O;
import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Rect;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.util.SparseArray;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewStructure;
import android.view.accessibility.AccessibilityManager;
import android.view.accessibility.AccessibilityNodeProvider;
import android.view.autofill.AutofillId;
import android.view.autofill.AutofillValue;
import android.view.textservice.SpellCheckerSession;
import android.view.textservice.TextServicesManager;
import android.widget.FrameLayout;
import g0.C0405a;
import io.flutter.embedding.engine.FlutterJNI;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.Executor;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.locks.ReentrantLock;
import y0.C0747k;
import y3.C0768i;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class r extends FrameLayout implements Q2.a, E {

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public final io.flutter.embedding.engine.renderer.i f229A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public final B.k f230B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public final o f231C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public final p f232D;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public final C0030e f233E;

    /* JADX INFO: renamed from: F, reason: collision with root package name */
    public C0039n f234F;

    /* JADX INFO: renamed from: G, reason: collision with root package name */
    public int f235G;

    /* JADX INFO: renamed from: H, reason: collision with root package name */
    public int f236H;

    /* JADX INFO: renamed from: I, reason: collision with root package name */
    public t f237I;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AtomicBoolean f238a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f239b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0035j f240c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final C0037l f241d;
    public C0033h e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public View f242f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public View f243m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final HashSet f244n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public boolean f245o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public E2.c f246p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final HashSet f247q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public v f248r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public io.flutter.plugin.editing.i f249s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public io.flutter.plugin.editing.g f250t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public P2.a f251u;
    public C0747k v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public C0026a f252w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public io.flutter.view.k f253x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public TextServicesManager f254y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public B.k f255z;

    public r(AbstractActivityC0029d abstractActivityC0029d, C0035j c0035j) {
        super(abstractActivityC0029d, null);
        this.f238a = new AtomicBoolean(true);
        this.f239b = false;
        this.f244n = new HashSet();
        this.f247q = new HashSet();
        this.f229A = new io.flutter.embedding.engine.renderer.i();
        this.f230B = new B.k(this, 1);
        this.f231C = new o(this, new Handler(Looper.getMainLooper()), 0);
        this.f232D = new p(this);
        this.f233E = new C0030e(this, 1);
        this.f237I = new t();
        this.f240c = c0035j;
        this.f242f = c0035j;
        b();
    }

    /* JADX WARN: Type inference failed for: r0v32, types: [android.view.View, io.flutter.embedding.engine.renderer.m] */
    public final void a() {
        SparseArray sparseArray;
        Objects.toString(this.f246p);
        if (c()) {
            Iterator it = this.f247q.iterator();
            if (it.hasNext()) {
                it.next().getClass();
                throw new ClassCastException();
            }
            getContext().getContentResolver().unregisterContentObserver(this.f231C);
            io.flutter.plugin.platform.q qVar = this.f246p.f358s;
            int i4 = 0;
            while (true) {
                SparseArray sparseArray2 = qVar.f4679u;
                if (i4 >= sparseArray2.size()) {
                    break;
                }
                qVar.f4669d.removeView((io.flutter.plugin.platform.i) sparseArray2.valueAt(i4));
                i4++;
            }
            int i5 = 0;
            while (true) {
                SparseArray sparseArray3 = qVar.f4677s;
                if (i5 >= sparseArray3.size()) {
                    break;
                }
                qVar.f4669d.removeView((J2.b) sparseArray3.valueAt(i5));
                i5++;
            }
            qVar.c();
            if (qVar.f4669d == null) {
                Log.e("PlatformViewsController", "removeOverlaySurfaces called while flutter view is null");
            } else {
                int i6 = 0;
                while (true) {
                    sparseArray = qVar.f4678t;
                    if (i6 >= sparseArray.size()) {
                        break;
                    }
                    qVar.f4669d.removeView((View) sparseArray.valueAt(i6));
                    i6++;
                }
                sparseArray.clear();
            }
            qVar.f4669d = null;
            qVar.f4680w = false;
            int i7 = 0;
            while (true) {
                SparseArray sparseArray4 = qVar.f4676r;
                if (i7 >= sparseArray4.size()) {
                    break;
                }
                ((io.flutter.plugin.platform.g) sparseArray4.valueAt(i7)).getClass();
                i7++;
            }
            io.flutter.plugin.platform.p pVar = this.f246p.f359t;
            int i8 = 0;
            while (true) {
                SparseArray sparseArray5 = pVar.f4656p;
                if (i8 >= sparseArray5.size()) {
                    break;
                }
                pVar.f4651d.removeView((J2.b) sparseArray5.valueAt(i8));
                i8++;
            }
            Surface surface = pVar.f4660t;
            if (surface != null) {
                surface.release();
                pVar.f4660t = null;
                pVar.f4661u = null;
            }
            pVar.f4651d = null;
            int i9 = 0;
            while (true) {
                SparseArray sparseArray6 = pVar.f4655o;
                if (i9 >= sparseArray6.size()) {
                    break;
                }
                ((io.flutter.plugin.platform.g) sparseArray6.valueAt(i9)).getClass();
                i9++;
            }
            this.f246p.f358s.d();
            this.f246p.f359t.d();
            io.flutter.view.k kVar = this.f253x;
            kVar.f4807u = true;
            kVar.e.d();
            kVar.f4805s = null;
            AccessibilityManager accessibilityManager = kVar.f4790c;
            accessibilityManager.removeAccessibilityStateChangeListener(kVar.v);
            accessibilityManager.removeTouchExplorationStateChangeListener(kVar.f4808w);
            kVar.f4792f.unregisterContentObserver(kVar.f4809x);
            C0747k c0747k = kVar.f4789b;
            c0747k.f6833d = null;
            ((FlutterJNI) c0747k.f6832c).setAccessibilityDelegate(null);
            this.f253x = null;
            this.f249s.f4587b.restartInput(this);
            this.f249s.c();
            int size = ((HashSet) this.v.f6832c).size();
            if (size > 0) {
                Log.w("KeyboardManager", "A KeyboardManager was destroyed with " + size + " unhandled redispatch event(s).");
            }
            io.flutter.plugin.editing.g gVar = this.f250t;
            if (gVar != null) {
                gVar.f4575a.f6969b = null;
                SpellCheckerSession spellCheckerSession = gVar.f4577c;
                if (spellCheckerSession != null) {
                    spellCheckerSession.close();
                }
            }
            v vVar = this.f248r;
            if (vVar != null) {
                ((C0779j) vVar.f261c).f6969b = null;
            }
            io.flutter.embedding.engine.renderer.j jVar = this.f246p.f342b;
            this.f245o = false;
            jVar.g(this.f233E);
            boolean z4 = this.f239b;
            FlutterJNI flutterJNI = jVar.f4535a;
            if (z4) {
                flutterJNI.removeResizingFlutterUiListener(this.f232D);
            }
            jVar.j();
            flutterJNI.setSemanticsEnabled(false);
            View view = this.f243m;
            if (view != null && this.f242f == this.e) {
                this.f242f = view;
            }
            this.f242f.d();
            C0033h c0033h = this.e;
            if (c0033h != null) {
                c0033h.f204a.close();
                removeView(this.e);
                this.e = null;
            }
            this.f243m = null;
            this.f246p = null;
        }
    }

    @Override // android.view.View
    public final void autofill(SparseArray sparseArray) {
        C0053n c0053n;
        C0053n c0053n2;
        io.flutter.plugin.editing.i iVar = this.f249s;
        if (Build.VERSION.SDK_INT < 26) {
            iVar.getClass();
            return;
        }
        N2.n nVar = iVar.f4590f;
        if (nVar == null || iVar.f4591g == null || (c0053n = nVar.f1187j) == null) {
            return;
        }
        HashMap map = new HashMap();
        for (int i4 = 0; i4 < sparseArray.size(); i4++) {
            N2.n nVar2 = (N2.n) iVar.f4591g.get(sparseArray.keyAt(i4));
            if (nVar2 != null && (c0053n2 = nVar2.f1187j) != null) {
                String string = B.d.h(sparseArray.valueAt(i4)).getTextValue().toString();
                N2.p pVar = new N2.p(string, string.length(), string.length(), -1, -1);
                String str = (String) c0053n2.f706b;
                if (str.equals((String) c0053n.f706b)) {
                    iVar.f4592h.f(pVar);
                } else {
                    map.put(str, pVar);
                }
            }
        }
        int i5 = iVar.e.f56c;
        v vVar = iVar.f4589d;
        vVar.getClass();
        map.size();
        HashMap map2 = new HashMap();
        for (Map.Entry entry : map.entrySet()) {
            N2.p pVar2 = (N2.p) entry.getValue();
            map2.put((String) entry.getKey(), v.k(pVar2.f1194a, pVar2.f1195b, pVar2.f1196c, -1, -1));
        }
        ((C0747k) vVar.f260b).O("TextInputClient.updateEditingStateWithTag", Arrays.asList(Integer.valueOf(i5), map2), null);
    }

    public final void b() {
        C0035j c0035j = this.f240c;
        if (c0035j != null) {
            addView(c0035j);
        } else {
            C0037l c0037l = this.f241d;
            if (c0037l != null) {
                addView(c0037l);
            } else {
                addView(this.e);
            }
        }
        this.f239b = H0.a.K(getContext());
        setFocusable(true);
        setFocusableInTouchMode(true);
        if (Build.VERSION.SDK_INT >= 26) {
            setImportantForAutofill(1);
        }
    }

    /* JADX WARN: Type inference failed for: r1v0, types: [android.view.View, io.flutter.embedding.engine.renderer.m] */
    public final boolean c() {
        E2.c cVar = this.f246p;
        if (cVar != null) {
            return cVar.f342b == this.f242f.getAttachedRenderer();
        }
        return false;
    }

    @Override // android.view.View
    public final boolean checkInputConnectionProxy(View view) {
        E2.c cVar = this.f246p;
        if (cVar == null) {
            return super.checkInputConnectionProxy(view);
        }
        io.flutter.plugin.platform.q qVar = cVar.f358s;
        if (view == null) {
            qVar.getClass();
            return false;
        }
        HashMap map = qVar.f4675q;
        if (!map.containsKey(view.getContext())) {
            return false;
        }
        View view2 = (View) map.get(view.getContext());
        if (view2 == view) {
            return true;
        }
        return view2.checkInputConnectionProxy(view);
    }

    /* JADX WARN: Removed duplicated region for block: B:21:0x004e  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void d() {
        /*
            Method dump skipped, instruction units count: 276
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.r.d():void");
    }

    @Override // android.view.ViewGroup, android.view.View
    public final boolean dispatchKeyEvent(KeyEvent keyEvent) {
        if (keyEvent.getAction() == 0 && keyEvent.getRepeatCount() == 0) {
            getKeyDispatcherState().startTracking(keyEvent, this);
        } else if (keyEvent.getAction() == 1) {
            getKeyDispatcherState().handleUpEvent(keyEvent);
        }
        return (c() && this.v.M(keyEvent)) || super.dispatchKeyEvent(keyEvent);
    }

    public final void e() {
        if (!c()) {
            Log.w("FlutterView", "Tried to send viewport metrics from Android to Flutter but this FlutterView was not attached to a FlutterEngine.");
            return;
        }
        float f4 = getResources().getDisplayMetrics().density;
        io.flutter.embedding.engine.renderer.i iVar = this.f229A;
        iVar.f4515a = f4;
        iVar.f4533t = ViewConfiguration.get(getContext()).getScaledTouchSlop();
        io.flutter.embedding.engine.renderer.j jVar = this.f246p.f342b;
        jVar.getClass();
        int i4 = iVar.f4516b;
        if (i4 == 0) {
            int i5 = iVar.f4518d;
            int i6 = iVar.e;
            if (i5 <= 0 && i6 <= 0) {
                return;
            }
        } else {
            int i7 = iVar.f4517c;
            if (i7 == 0) {
                int i8 = iVar.f4519f;
                int i9 = iVar.f4520g;
                if (i8 <= 0 && i9 <= 0) {
                    return;
                }
            } else if (i4 <= 0 || i7 <= 0 || iVar.f4515a <= 0.0f) {
                return;
            }
        }
        ArrayList arrayList = iVar.f4534u;
        arrayList.size();
        ArrayList arrayList2 = iVar.v;
        arrayList2.size();
        int size = arrayList2.size() + arrayList.size();
        int[] iArr = new int[size * 4];
        int[] iArr2 = new int[size];
        int[] iArr3 = new int[size];
        for (int i10 = 0; i10 < arrayList.size(); i10++) {
            io.flutter.embedding.engine.renderer.a aVar = (io.flutter.embedding.engine.renderer.a) arrayList.get(i10);
            int i11 = i10 * 4;
            Rect rect = aVar.f4496a;
            iArr[i11] = rect.left;
            iArr[i11 + 1] = rect.top;
            iArr[i11 + 2] = rect.right;
            iArr[i11 + 3] = rect.bottom;
            iArr2[i10] = K.j.b(aVar.f4497b);
            iArr3[i10] = K.j.b(aVar.f4498c);
        }
        int size2 = arrayList.size() * 4;
        for (int i12 = 0; i12 < arrayList2.size(); i12++) {
            io.flutter.embedding.engine.renderer.a aVar2 = (io.flutter.embedding.engine.renderer.a) arrayList2.get(i12);
            int i13 = (i12 * 4) + size2;
            Rect rect2 = aVar2.f4496a;
            iArr[i13] = rect2.left;
            iArr[i13 + 1] = rect2.top;
            iArr[i13 + 2] = rect2.right;
            iArr[i13 + 3] = rect2.bottom;
            iArr2[arrayList.size() + i12] = K.j.b(aVar2.f4497b);
            iArr3[arrayList.size() + i12] = K.j.b(aVar2.f4498c);
        }
        jVar.f4535a.setViewportMetrics(iVar.f4515a, iVar.f4516b, iVar.f4517c, iVar.f4521h, iVar.f4522i, iVar.f4523j, iVar.f4524k, iVar.f4525l, iVar.f4526m, iVar.f4527n, iVar.f4528o, iVar.f4529p, iVar.f4530q, iVar.f4531r, iVar.f4532s, iVar.f4533t, iArr, iArr2, iArr3, iVar.f4518d, iVar.e, iVar.f4519f, iVar.f4520g);
    }

    @Override // android.view.View
    public AccessibilityNodeProvider getAccessibilityNodeProvider() {
        io.flutter.view.k kVar = this.f253x;
        if (kVar == null || !kVar.f4790c.isEnabled()) {
            return null;
        }
        return this.f253x;
    }

    public E2.c getAttachedFlutterEngine() {
        return this.f246p;
    }

    public O2.f getBinaryMessenger() {
        return this.f246p.f343c;
    }

    public C0033h getCurrentImageSurface() {
        return this.e;
    }

    public io.flutter.embedding.engine.renderer.i getViewportMetrics() {
        return this.f229A;
    }

    /* JADX WARN: Removed duplicated region for block: B:30:0x0135  */
    /* JADX WARN: Removed duplicated region for block: B:32:0x0138  */
    /* JADX WARN: Removed duplicated region for block: B:33:0x013d  */
    /* JADX WARN: Removed duplicated region for block: B:39:0x014a  */
    /* JADX WARN: Removed duplicated region for block: B:42:0x014f  */
    /* JADX WARN: Removed duplicated region for block: B:48:0x0174  */
    /* JADX WARN: Removed duplicated region for block: B:52:0x017e A[ADDED_TO_REGION] */
    /* JADX WARN: Removed duplicated region for block: B:55:0x0186  */
    /* JADX WARN: Removed duplicated region for block: B:58:0x01a0  */
    /* JADX WARN: Removed duplicated region for block: B:59:0x01a2  */
    @Override // android.view.View
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final android.view.WindowInsets onApplyWindowInsets(android.view.WindowInsets r18) {
        /*
            Method dump skipped, instruction units count: 564
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.r.onApplyWindowInsets(android.view.WindowInsets):android.view.WindowInsets");
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onAttachedToWindow() {
        B.k kVar;
        super.onAttachedToWindow();
        try {
            i0.g gVar = i0.h.f4477k;
            Context context = getContext();
            gVar.getClass();
            kVar = new B.k(new com.google.android.gms.common.internal.r(i0.g.a(context)), 2);
        } catch (NoClassDefFoundError unused) {
            kVar = null;
        }
        this.f255z = kVar;
        Activity activityR = e1.k.r(getContext());
        B.k kVar2 = this.f255z;
        if (kVar2 == null || activityR == null) {
            return;
        }
        this.f234F = new C0039n(this, 0);
        Executor mainExecutor = r.h.getMainExecutor(getContext());
        C0039n c0039n = this.f234F;
        com.google.android.gms.common.internal.r rVar = (com.google.android.gms.common.internal.r) kVar2.f104b;
        J3.i.e(mainExecutor, "executor");
        J3.i.e(c0039n, "consumer");
        i0.b bVar = (i0.b) rVar.f3597b;
        bVar.getClass();
        i0.i iVar = new i0.i(bVar, activityR, null);
        C0768i c0768i = C0768i.f6945a;
        T3.c cVar = new T3.c(iVar, c0768i, -2, S3.c.f1813a);
        X3.e eVar = O.f1596a;
        R3.d dVar = V3.o.f2244a;
        if (dVar.i(Q3.B.f1565b) != null) {
            throw new IllegalArgumentException(("Flow context cannot contain job in it. Had " + dVar).toString());
        }
        T3.d dVarA = cVar;
        if (!dVar.equals(c0768i)) {
            dVarA = U3.k.a(cVar, dVar, 0, null, 6);
        }
        com.google.android.gms.common.internal.r rVar2 = (com.google.android.gms.common.internal.r) rVar.f3598c;
        rVar2.getClass();
        J3.i.e(dVarA, "flow");
        ReentrantLock reentrantLock = (ReentrantLock) rVar2.f3597b;
        reentrantLock.lock();
        LinkedHashMap linkedHashMap = (LinkedHashMap) rVar2.f3598c;
        try {
            if (linkedHashMap.get(c0039n) == null) {
                linkedHashMap.put(c0039n, Q3.F.s(Q3.F.b(new C0120b0(mainExecutor)), null, new C0405a(dVarA, c0039n, null), 3));
            }
        } finally {
            reentrantLock.unlock();
        }
    }

    @Override // android.view.View
    public final void onConfigurationChanged(Configuration configuration) throws Exception {
        super.onConfigurationChanged(configuration);
        if (this.f246p != null) {
            this.f251u.b(configuration);
            d();
            e1.k.c(getContext(), this.f246p);
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:32:0x0052 A[PHI: r6
      0x0052: PHI (r6v19 int) = (r6v12 int), (r6v22 int) binds: [B:76:0x00b5, B:31:0x0050] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:75:0x00b2  */
    /* JADX WARN: Removed duplicated region for block: B:76:0x00b5  */
    @Override // android.view.View
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final android.view.inputmethod.InputConnection onCreateInputConnection(android.view.inputmethod.EditorInfo r11) {
        /*
            Method dump skipped, instruction units count: 345
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.r.onCreateInputConnection(android.view.inputmethod.EditorInfo):android.view.inputmethod.InputConnection");
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onDetachedFromWindow() {
        C0039n c0039n;
        B.k kVar = this.f255z;
        if (kVar != null && (c0039n = this.f234F) != null) {
            com.google.android.gms.common.internal.r rVar = (com.google.android.gms.common.internal.r) ((com.google.android.gms.common.internal.r) kVar.f104b).f3598c;
            rVar.getClass();
            ReentrantLock reentrantLock = (ReentrantLock) rVar.f3597b;
            reentrantLock.lock();
            LinkedHashMap linkedHashMap = (LinkedHashMap) rVar.f3598c;
            try {
                InterfaceC0132h0 interfaceC0132h0 = (InterfaceC0132h0) linkedHashMap.get(c0039n);
                if (interfaceC0132h0 != null) {
                    interfaceC0132h0.a(null);
                }
            } finally {
                reentrantLock.unlock();
            }
        }
        this.f234F = null;
        this.f255z = null;
        super.onDetachedFromWindow();
    }

    @Override // android.view.View
    public final boolean onGenericMotionEvent(MotionEvent motionEvent) {
        if (c()) {
            C0026a c0026a = this.f252w;
            Context context = getContext();
            c0026a.getClass();
            boolean zIsFromSource = motionEvent.isFromSource(2);
            boolean z4 = motionEvent.getActionMasked() == 7 || motionEvent.getActionMasked() == 8;
            if (zIsFromSource && z4) {
                int iB = C0026a.b(motionEvent.getActionMasked());
                ByteBuffer byteBufferAllocateDirect = ByteBuffer.allocateDirect(motionEvent.getPointerCount() * 288);
                byteBufferAllocateDirect.order(ByteOrder.LITTLE_ENDIAN);
                c0026a.a(motionEvent, motionEvent.getActionIndex(), iB, 0, C0026a.f177f, byteBufferAllocateDirect, context);
                if (byteBufferAllocateDirect.position() % 288 != 0) {
                    throw new AssertionError("Packet position is not on field boundary.");
                }
                c0026a.f178a.f4535a.dispatchPointerDataPacket(byteBufferAllocateDirect, byteBufferAllocateDirect.position());
                return true;
            }
        }
        return super.onGenericMotionEvent(motionEvent);
    }

    @Override // android.view.View
    public final boolean onHoverEvent(MotionEvent motionEvent) {
        return !c() ? super.onHoverEvent(motionEvent) : this.f253x.f(motionEvent, false);
    }

    @Override // android.widget.FrameLayout, android.view.View
    public final void onMeasure(int i4, int i5) {
        this.f235G = View.MeasureSpec.getMode(i4);
        this.f236H = View.MeasureSpec.getMode(i5);
        super.onMeasure(i4, i5);
    }

    @Override // android.view.View
    public final void onProvideAutofillVirtualStructure(ViewStructure viewStructure, int i4) {
        Rect rect;
        super.onProvideAutofillVirtualStructure(viewStructure, i4);
        io.flutter.plugin.editing.i iVar = this.f249s;
        if (Build.VERSION.SDK_INT < 26) {
            iVar.getClass();
            return;
        }
        if (iVar.f4591g != null) {
            String str = (String) iVar.f4590f.f1187j.f706b;
            AutofillId autofillId = viewStructure.getAutofillId();
            for (int i5 = 0; i5 < iVar.f4591g.size(); i5++) {
                int iKeyAt = iVar.f4591g.keyAt(i5);
                C0053n c0053n = ((N2.n) iVar.f4591g.valueAt(i5)).f1187j;
                if (c0053n != null) {
                    viewStructure.addChildCount(1);
                    ViewStructure viewStructureNewChild = viewStructure.newChild(i5);
                    viewStructureNewChild.setAutofillId(autofillId, iKeyAt);
                    String[] strArr = (String[]) c0053n.f707c;
                    if (strArr.length > 0) {
                        viewStructureNewChild.setAutofillHints(strArr);
                    }
                    viewStructureNewChild.setAutofillType(1);
                    viewStructureNewChild.setVisibility(0);
                    String str2 = (String) c0053n.e;
                    if (str2 != null) {
                        viewStructureNewChild.setHint(str2);
                    }
                    if (str.hashCode() != iKeyAt || (rect = iVar.f4597m) == null) {
                        viewStructureNewChild.setDimens(0, 0, 0, 0, 1, 1);
                        viewStructureNewChild.setAutofillValue(AutofillValue.forText(((N2.p) c0053n.f708d).f1194a));
                    } else {
                        viewStructureNewChild.setDimens(rect.left, rect.top, 0, 0, rect.width(), iVar.f4597m.height());
                        viewStructureNewChild.setAutofillValue(AutofillValue.forText(iVar.f4592h));
                    }
                }
            }
        }
    }

    @Override // android.view.View
    public final void onSizeChanged(int i4, int i5, int i6, int i7) {
        super.onSizeChanged(i4, i5, i6, i7);
        io.flutter.embedding.engine.renderer.i iVar = this.f229A;
        iVar.f4516b = i4;
        iVar.f4517c = i5;
        boolean z4 = this.f239b;
        if (z4 && this.f236H == 0) {
            iVar.f4519f = 0;
            iVar.f4520g = 8192;
        } else {
            iVar.f4519f = i5;
            iVar.f4520g = i5;
        }
        if (z4 && this.f235G == 0) {
            iVar.f4518d = 0;
            iVar.e = 8192;
        } else {
            iVar.f4518d = i4;
            iVar.e = i4;
        }
        if (this.f238a.compareAndSet(false, true)) {
            return;
        }
        e();
    }

    @Override // android.view.View
    public final boolean onTouchEvent(MotionEvent motionEvent) {
        if (!c()) {
            return super.onTouchEvent(motionEvent);
        }
        requestUnbufferedDispatch(motionEvent);
        this.f252w.d(motionEvent, C0026a.f177f);
        return true;
    }

    public void setDelegate(t tVar) {
        this.f237I = tVar;
    }

    @Override // android.view.View
    public void setVisibility(int i4) {
        super.setVisibility(i4);
        View view = this.f242f;
        if (view instanceof C0035j) {
            ((C0035j) view).setVisibility(i4);
        }
    }

    /* JADX WARN: Type inference failed for: r8v1, types: [java.lang.Object, java.util.List] */
    public void setWindowInfoListenerDisplayFeatures(i0.j jVar) {
        ?? r8 = jVar.f4482a;
        ArrayList arrayList = new ArrayList();
        for (i0.c cVar : r8) {
            cVar.f4465a.a().toString();
            f0.b bVar = cVar.f4465a;
            int i4 = bVar.f4267c - bVar.f4265a;
            i0.b bVar2 = i0.b.f4459d;
            int i5 = 2;
            int i6 = ((i4 == 0 || bVar.f4268d - bVar.f4266b == 0) ? i0.b.f4458c : bVar2) == bVar2 ? 3 : 2;
            i0.b bVar3 = i0.b.e;
            i0.b bVar4 = cVar.f4467c;
            if (bVar4 != bVar3) {
                i5 = bVar4 == i0.b.f4460f ? 3 : 1;
            }
            arrayList.add(new io.flutter.embedding.engine.renderer.a(bVar.a(), i6, i5));
        }
        ArrayList arrayList2 = this.f229A.f4534u;
        arrayList2.clear();
        arrayList2.addAll(arrayList);
        e();
    }

    public r(AbstractActivityC0029d abstractActivityC0029d, C0037l c0037l) {
        super(abstractActivityC0029d, null);
        this.f238a = new AtomicBoolean(true);
        this.f239b = false;
        this.f244n = new HashSet();
        this.f247q = new HashSet();
        this.f229A = new io.flutter.embedding.engine.renderer.i();
        this.f230B = new B.k(this, 1);
        this.f231C = new o(this, new Handler(Looper.getMainLooper()), 0);
        this.f232D = new p(this);
        this.f233E = new C0030e(this, 1);
        this.f237I = new t();
        this.f241d = c0037l;
        this.f242f = c0037l;
        b();
    }
}
