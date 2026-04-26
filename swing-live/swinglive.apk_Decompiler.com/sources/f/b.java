package F;

import A.C;
import O.AbstractComponentCallbacksC0109u;
import O.DialogInterfaceOnCancelListenerC0106q;
import O.N;
import X.C0172c;
import X.C0176g;
import X.s;
import android.animation.ValueAnimator;
import android.os.SystemClock;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.animation.AnimationUtils;
import android.widget.ListView;
import androidx.appcompat.widget.ActionMenuView;
import androidx.appcompat.widget.Toolbar;
import androidx.lifecycle.u;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;
import com.google.android.gms.common.api.internal.E;
import com.google.android.gms.common.api.internal.O;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Iterator;
import k.AbstractC0474B;
import k.C0492i;
import l3.C0523A;
import z0.C0771b;

/* JADX INFO: loaded from: classes.dex */
public final class b implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f389a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f390b;

    public /* synthetic */ b(Object obj, int i4) {
        this.f389a = i4;
        this.f390b = obj;
    }

    @Override // java.lang.Runnable
    public final void run() {
        Object obj;
        C0492i c0492i;
        switch (this.f389a) {
            case 0:
                g gVar = (g) this.f390b;
                if (gVar.f406u) {
                    boolean z4 = gVar.f404s;
                    a aVar = gVar.f393a;
                    if (z4) {
                        gVar.f404s = false;
                        long jCurrentAnimationTimeMillis = AnimationUtils.currentAnimationTimeMillis();
                        aVar.e = jCurrentAnimationTimeMillis;
                        aVar.f386g = -1L;
                        aVar.f385f = jCurrentAnimationTimeMillis;
                        aVar.f387h = 0.5f;
                    }
                    if ((aVar.f386g > 0 && AnimationUtils.currentAnimationTimeMillis() > aVar.f386g + ((long) aVar.f388i)) || !gVar.e()) {
                        gVar.f406u = false;
                        return;
                    }
                    boolean z5 = gVar.f405t;
                    ListView listView = gVar.f395c;
                    if (z5) {
                        gVar.f405t = false;
                        long jUptimeMillis = SystemClock.uptimeMillis();
                        MotionEvent motionEventObtain = MotionEvent.obtain(jUptimeMillis, jUptimeMillis, 3, 0.0f, 0.0f, 0);
                        listView.onTouchEvent(motionEventObtain);
                        motionEventObtain.recycle();
                    }
                    if (aVar.f385f == 0) {
                        throw new RuntimeException("Cannot compute scroll delta before calling start()");
                    }
                    long jCurrentAnimationTimeMillis2 = AnimationUtils.currentAnimationTimeMillis();
                    float fA = aVar.a(jCurrentAnimationTimeMillis2);
                    long j4 = jCurrentAnimationTimeMillis2 - aVar.f385f;
                    aVar.f385f = jCurrentAnimationTimeMillis2;
                    gVar.f407w.scrollListBy((int) (j4 * ((fA * 4.0f) + ((-4.0f) * fA * fA)) * aVar.f384d));
                    Field field = C.f4a;
                    listView.postOnAnimation(this);
                    return;
                }
                return;
            case 1:
                DialogInterfaceOnCancelListenerC0106q dialogInterfaceOnCancelListenerC0106q = (DialogInterfaceOnCancelListenerC0106q) this.f390b;
                dialogInterfaceOnCancelListenerC0106q.f1362Z.onDismiss(dialogInterfaceOnCancelListenerC0106q.h0);
                return;
            case 2:
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = (AbstractComponentCallbacksC0109u) this.f390b;
                if (abstractComponentCallbacksC0109u.f1398N != null) {
                    abstractComponentCallbacksC0109u.l().getClass();
                    return;
                }
                return;
            case 3:
                ((N) this.f390b).z(true);
                return;
            case 4:
                C0176g c0176g = (C0176g) this.f390b;
                int i4 = c0176g.v;
                ValueAnimator valueAnimator = c0176g.f2345u;
                if (i4 == 1) {
                    valueAnimator.cancel();
                } else if (i4 != 2) {
                    return;
                }
                c0176g.v = 3;
                valueAnimator.setFloatValues(((Float) valueAnimator.getAnimatedValue()).floatValue(), 0.0f);
                valueAnimator.setDuration(500);
                valueAnimator.start();
                return;
            case 5:
                s sVar = ((RecyclerView) this.f390b).J;
                if (sVar != null) {
                    C0172c c0172c = (C0172c) sVar;
                    ArrayList arrayList = c0172c.e;
                    boolean zIsEmpty = arrayList.isEmpty();
                    ArrayList arrayList2 = c0172c.f2312g;
                    boolean zIsEmpty2 = arrayList2.isEmpty();
                    ArrayList arrayList3 = c0172c.f2313h;
                    boolean zIsEmpty3 = arrayList3.isEmpty();
                    ArrayList arrayList4 = c0172c.f2311f;
                    boolean zIsEmpty4 = arrayList4.isEmpty();
                    if (zIsEmpty && zIsEmpty2 && zIsEmpty4 && zIsEmpty3) {
                        return;
                    }
                    Iterator it = arrayList.iterator();
                    if (it.hasNext()) {
                        it.next().getClass();
                        throw new ClassCastException();
                    }
                    arrayList.clear();
                    if (!zIsEmpty2) {
                        ArrayList arrayList5 = new ArrayList();
                        arrayList5.addAll(arrayList2);
                        ArrayList arrayList6 = c0172c.f2315j;
                        arrayList6.add(arrayList5);
                        arrayList2.clear();
                        if (!zIsEmpty) {
                            B1.a.p(arrayList5.get(0));
                            throw null;
                        }
                        Iterator it2 = arrayList5.iterator();
                        if (it2.hasNext()) {
                            B1.a.p(it2.next());
                            throw null;
                        }
                        arrayList5.clear();
                        arrayList6.remove(arrayList5);
                    }
                    if (!zIsEmpty3) {
                        ArrayList arrayList7 = new ArrayList();
                        arrayList7.addAll(arrayList3);
                        ArrayList arrayList8 = c0172c.f2316k;
                        arrayList8.add(arrayList7);
                        arrayList3.clear();
                        if (!zIsEmpty) {
                            B1.a.p(arrayList7.get(0));
                            throw null;
                        }
                        Iterator it3 = arrayList7.iterator();
                        if (it3.hasNext()) {
                            B1.a.p(it3.next());
                            throw null;
                        }
                        arrayList7.clear();
                        arrayList8.remove(arrayList7);
                    }
                    if (zIsEmpty4) {
                        return;
                    }
                    ArrayList arrayList9 = new ArrayList();
                    arrayList9.addAll(arrayList4);
                    ArrayList arrayList10 = c0172c.f2314i;
                    arrayList10.add(arrayList9);
                    arrayList4.clear();
                    if (!zIsEmpty || !zIsEmpty2 || !zIsEmpty3) {
                        Math.max(!zIsEmpty2 ? c0172c.f2369c : 0L, zIsEmpty3 ? 0L : c0172c.f2370d);
                        arrayList9.get(0).getClass();
                        throw new ClassCastException();
                    }
                    Iterator it4 = arrayList9.iterator();
                    if (it4.hasNext()) {
                        it4.next().getClass();
                        throw new ClassCastException();
                    }
                    arrayList9.clear();
                    arrayList10.remove(arrayList9);
                    return;
                }
                return;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                ((StaggeredGridLayoutManager) this.f390b).J();
                return;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                synchronized (((u) this.f390b).f3090a) {
                    obj = ((u) this.f390b).f3094f;
                    ((u) this.f390b).f3094f = u.f3089k;
                    break;
                }
                ((u) this.f390b).h(obj);
                return;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                try {
                    super/*android.app.Activity*/.onBackPressed();
                    return;
                } catch (IllegalStateException e) {
                    if (!TextUtils.equals(e.getMessage(), "Can not perform this action after onSaveInstanceState")) {
                        throw e;
                    }
                    return;
                } catch (NullPointerException e4) {
                    if (!TextUtils.equals(e4.getMessage(), "Attempt to invoke virtual method 'android.os.Handler android.app.FragmentHostCallback.getHandler()' on a null object reference")) {
                        throw e4;
                    }
                    return;
                }
            case 9:
                ((E) this.f390b).h();
                return;
            case 10:
                com.google.android.gms.common.api.g gVar2 = ((E) ((B.k) this.f390b).f104b).f3394b;
                gVar2.disconnect(gVar2.getClass().getName().concat(" disconnecting because it was signed out."));
                return;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                ((O) this.f390b).f3432g.b(new C0771b(4));
                return;
            case 12:
                AbstractC0474B abstractC0474B = (AbstractC0474B) this.f390b;
                abstractC0474B.f5264s = null;
                abstractC0474B.drawableStateChanged();
                return;
            case 13:
                ActionMenuView actionMenuView = ((Toolbar) this.f390b).f2825a;
                if (actionMenuView == null || (c0492i = actionMenuView.f2720y) == null) {
                    return;
                }
                c0492i.h();
                return;
            default:
                Object obj2 = ((C0523A) this.f390b).f5626a;
                return;
        }
    }

    public b(C0523A c0523a, int i4) {
        this.f389a = 14;
        this.f390b = c0523a;
    }
}
