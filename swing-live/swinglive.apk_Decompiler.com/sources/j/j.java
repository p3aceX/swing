package j;

import A.E;
import A.G;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.content.res.Resources;
import android.os.Build;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;
import android.view.ViewConfiguration;
import androidx.appcompat.widget.ActionMenuView;
import androidx.appcompat.widget.Toolbar;
import java.lang.ref.WeakReference;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import k.InterfaceC0495l;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public class j implements Menu {

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public static final int[] f5080u = {1, 4, 5, 3, 2, 0};

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f5081a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Resources f5082b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f5083c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f5084d;
    public C0779j e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final ArrayList f5085f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final ArrayList f5086g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public boolean f5087h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final ArrayList f5088i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final ArrayList f5089j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public boolean f5090k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public CharSequence f5091l;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public k f5098s;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public boolean f5092m = false;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public boolean f5093n = false;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public boolean f5094o = false;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public boolean f5095p = false;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final ArrayList f5096q = new ArrayList();

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final CopyOnWriteArrayList f5097r = new CopyOnWriteArrayList();

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public boolean f5099t = false;

    public j(Context context) {
        boolean zB;
        boolean z4 = false;
        this.f5081a = context;
        Resources resources = context.getResources();
        this.f5082b = resources;
        this.f5085f = new ArrayList();
        this.f5086g = new ArrayList();
        this.f5087h = true;
        this.f5088i = new ArrayList();
        this.f5089j = new ArrayList();
        this.f5090k = true;
        if (resources.getConfiguration().keyboard != 1) {
            ViewConfiguration viewConfiguration = ViewConfiguration.get(context);
            Method method = G.f6a;
            if (Build.VERSION.SDK_INT >= 28) {
                zB = E.b(viewConfiguration);
            } else {
                Resources resources2 = context.getResources();
                int identifier = resources2.getIdentifier("config_showMenuShortcutsWhenKeyboardPresent", "bool", "android");
                zB = identifier != 0 && resources2.getBoolean(identifier);
            }
            if (zB) {
                z4 = true;
            }
        }
        this.f5084d = z4;
    }

    public final k a(int i4, int i5, int i6, CharSequence charSequence) {
        int i7;
        int i8 = ((-65536) & i6) >> 16;
        if (i8 < 0 || i8 >= 6) {
            throw new IllegalArgumentException("order does not contain a valid category.");
        }
        int i9 = (f5080u[i8] << 16) | (65535 & i6);
        k kVar = new k(this, i4, i5, i6, i9, charSequence);
        ArrayList arrayList = this.f5085f;
        int size = arrayList.size() - 1;
        while (true) {
            if (size < 0) {
                i7 = 0;
                break;
            }
            if (((k) arrayList.get(size)).f5105d <= i9) {
                i7 = size + 1;
                break;
            }
            size--;
        }
        arrayList.add(i7, kVar);
        o(true);
        return kVar;
    }

    @Override // android.view.Menu
    public final MenuItem add(CharSequence charSequence) {
        return a(0, 0, 0, charSequence);
    }

    @Override // android.view.Menu
    public final int addIntentOptions(int i4, int i5, int i6, ComponentName componentName, Intent[] intentArr, Intent intent, int i7, MenuItem[] menuItemArr) {
        int i8;
        PackageManager packageManager = this.f5081a.getPackageManager();
        List<ResolveInfo> listQueryIntentActivityOptions = packageManager.queryIntentActivityOptions(componentName, intentArr, intent, 0);
        int size = listQueryIntentActivityOptions != null ? listQueryIntentActivityOptions.size() : 0;
        if ((i7 & 1) == 0) {
            removeGroup(i4);
        }
        for (int i9 = 0; i9 < size; i9++) {
            ResolveInfo resolveInfo = listQueryIntentActivityOptions.get(i9);
            int i10 = resolveInfo.specificIndex;
            Intent intent2 = new Intent(i10 < 0 ? intent : intentArr[i10]);
            ActivityInfo activityInfo = resolveInfo.activityInfo;
            intent2.setComponent(new ComponentName(activityInfo.applicationInfo.packageName, activityInfo.name));
            k kVarA = a(i4, i5, i6, resolveInfo.loadLabel(packageManager));
            kVarA.setIcon(resolveInfo.loadIcon(packageManager));
            kVarA.f5107g = intent2;
            if (menuItemArr != null && (i8 = resolveInfo.specificIndex) >= 0) {
                menuItemArr[i8] = kVarA;
            }
        }
        return size;
    }

    @Override // android.view.Menu
    public final SubMenu addSubMenu(CharSequence charSequence) {
        return addSubMenu(0, 0, 0, charSequence);
    }

    public final void b(p pVar, Context context) {
        this.f5097r.add(new WeakReference(pVar));
        pVar.c(context, this);
        this.f5090k = true;
    }

    public final void c(boolean z4) {
        if (this.f5095p) {
            return;
        }
        this.f5095p = true;
        CopyOnWriteArrayList<WeakReference> copyOnWriteArrayList = this.f5097r;
        for (WeakReference weakReference : copyOnWriteArrayList) {
            p pVar = (p) weakReference.get();
            if (pVar == null) {
                copyOnWriteArrayList.remove(weakReference);
            } else {
                pVar.a(this, z4);
            }
        }
        this.f5095p = false;
    }

    @Override // android.view.Menu
    public final void clear() {
        k kVar = this.f5098s;
        if (kVar != null) {
            d(kVar);
        }
        this.f5085f.clear();
        o(true);
    }

    public final void clearHeader() {
        this.f5091l = null;
        o(false);
    }

    @Override // android.view.Menu
    public final void close() {
        c(true);
    }

    public boolean d(k kVar) {
        CopyOnWriteArrayList<WeakReference> copyOnWriteArrayList = this.f5097r;
        boolean zI = false;
        if (!copyOnWriteArrayList.isEmpty() && this.f5098s == kVar) {
            s();
            for (WeakReference weakReference : copyOnWriteArrayList) {
                p pVar = (p) weakReference.get();
                if (pVar != null) {
                    zI = pVar.i(kVar);
                    if (zI) {
                        break;
                    }
                } else {
                    copyOnWriteArrayList.remove(weakReference);
                }
            }
            r();
            if (zI) {
                this.f5098s = null;
            }
        }
        return zI;
    }

    public boolean e(j jVar, MenuItem menuItem) {
        InterfaceC0495l interfaceC0495l;
        C0779j c0779j = this.e;
        if (c0779j == null || (interfaceC0495l = ((ActionMenuView) c0779j.f6969b).f2717D) == null) {
            return false;
        }
        ((Toolbar) ((B.k) interfaceC0495l).f104b).getClass();
        return false;
    }

    public boolean f(k kVar) {
        CopyOnWriteArrayList<WeakReference> copyOnWriteArrayList = this.f5097r;
        boolean zE = false;
        if (copyOnWriteArrayList.isEmpty()) {
            return false;
        }
        s();
        for (WeakReference weakReference : copyOnWriteArrayList) {
            p pVar = (p) weakReference.get();
            if (pVar != null) {
                zE = pVar.e(kVar);
                if (zE) {
                    break;
                }
            } else {
                copyOnWriteArrayList.remove(weakReference);
            }
        }
        r();
        if (zE) {
            this.f5098s = kVar;
        }
        return zE;
    }

    @Override // android.view.Menu
    public final MenuItem findItem(int i4) {
        MenuItem menuItemFindItem;
        ArrayList arrayList = this.f5085f;
        int size = arrayList.size();
        for (int i5 = 0; i5 < size; i5++) {
            k kVar = (k) arrayList.get(i5);
            if (kVar.f5102a == i4) {
                return kVar;
            }
            if (kVar.hasSubMenu() && (menuItemFindItem = kVar.f5115o.findItem(i4)) != null) {
                return menuItemFindItem;
            }
        }
        return null;
    }

    public final k g(int i4, KeyEvent keyEvent) {
        ArrayList arrayList = this.f5096q;
        arrayList.clear();
        h(arrayList, i4, keyEvent);
        if (arrayList.isEmpty()) {
            return null;
        }
        int metaState = keyEvent.getMetaState();
        KeyCharacterMap.KeyData keyData = new KeyCharacterMap.KeyData();
        keyEvent.getKeyData(keyData);
        int size = arrayList.size();
        if (size == 1) {
            return (k) arrayList.get(0);
        }
        boolean zM = m();
        for (int i5 = 0; i5 < size; i5++) {
            k kVar = (k) arrayList.get(i5);
            char c5 = zM ? kVar.f5110j : kVar.f5108h;
            char[] cArr = keyData.meta;
            if ((c5 == cArr[0] && (metaState & 2) == 0) || ((c5 == cArr[2] && (metaState & 2) != 0) || (zM && c5 == '\b' && i4 == 67))) {
                return kVar;
            }
        }
        return null;
    }

    @Override // android.view.Menu
    public final MenuItem getItem(int i4) {
        return (MenuItem) this.f5085f.get(i4);
    }

    public final void h(ArrayList arrayList, int i4, KeyEvent keyEvent) {
        boolean zM = m();
        int modifiers = keyEvent.getModifiers();
        KeyCharacterMap.KeyData keyData = new KeyCharacterMap.KeyData();
        if (keyEvent.getKeyData(keyData) || i4 == 67) {
            ArrayList arrayList2 = this.f5085f;
            int size = arrayList2.size();
            for (int i5 = 0; i5 < size; i5++) {
                k kVar = (k) arrayList2.get(i5);
                if (kVar.hasSubMenu()) {
                    kVar.f5115o.h(arrayList, i4, keyEvent);
                }
                char c5 = zM ? kVar.f5110j : kVar.f5108h;
                if ((modifiers & 69647) == ((zM ? kVar.f5111k : kVar.f5109i) & 69647) && c5 != 0) {
                    char[] cArr = keyData.meta;
                    if ((c5 == cArr[0] || c5 == cArr[2] || (zM && c5 == '\b' && i4 == 67)) && kVar.isEnabled()) {
                        arrayList.add(kVar);
                    }
                }
            }
        }
    }

    @Override // android.view.Menu
    public final boolean hasVisibleItems() {
        ArrayList arrayList = this.f5085f;
        int size = arrayList.size();
        for (int i4 = 0; i4 < size; i4++) {
            if (((k) arrayList.get(i4)).isVisible()) {
                return true;
            }
        }
        return false;
    }

    public final void i() {
        ArrayList arrayListK = k();
        if (this.f5090k) {
            CopyOnWriteArrayList<WeakReference> copyOnWriteArrayList = this.f5097r;
            boolean zD = false;
            for (WeakReference weakReference : copyOnWriteArrayList) {
                p pVar = (p) weakReference.get();
                if (pVar == null) {
                    copyOnWriteArrayList.remove(weakReference);
                } else {
                    zD |= pVar.d();
                }
            }
            ArrayList arrayList = this.f5088i;
            ArrayList arrayList2 = this.f5089j;
            if (zD) {
                arrayList.clear();
                arrayList2.clear();
                int size = arrayListK.size();
                for (int i4 = 0; i4 < size; i4++) {
                    k kVar = (k) arrayListK.get(i4);
                    if ((kVar.f5123x & 32) == 32) {
                        arrayList.add(kVar);
                    } else {
                        arrayList2.add(kVar);
                    }
                }
            } else {
                arrayList.clear();
                arrayList2.clear();
                arrayList2.addAll(k());
            }
            this.f5090k = false;
        }
    }

    @Override // android.view.Menu
    public final boolean isShortcutKey(int i4, KeyEvent keyEvent) {
        return g(i4, keyEvent) != null;
    }

    public final ArrayList k() {
        boolean z4 = this.f5087h;
        ArrayList arrayList = this.f5086g;
        if (!z4) {
            return arrayList;
        }
        arrayList.clear();
        ArrayList arrayList2 = this.f5085f;
        int size = arrayList2.size();
        for (int i4 = 0; i4 < size; i4++) {
            k kVar = (k) arrayList2.get(i4);
            if (kVar.isVisible()) {
                arrayList.add(kVar);
            }
        }
        this.f5087h = false;
        this.f5090k = true;
        return arrayList;
    }

    public boolean l() {
        return this.f5099t;
    }

    public boolean m() {
        return this.f5083c;
    }

    public boolean n() {
        return this.f5084d;
    }

    public final void o(boolean z4) {
        if (this.f5092m) {
            this.f5093n = true;
            if (z4) {
                this.f5094o = true;
                return;
            }
            return;
        }
        if (z4) {
            this.f5087h = true;
            this.f5090k = true;
        }
        CopyOnWriteArrayList<WeakReference> copyOnWriteArrayList = this.f5097r;
        if (copyOnWriteArrayList.isEmpty()) {
            return;
        }
        s();
        for (WeakReference weakReference : copyOnWriteArrayList) {
            p pVar = (p) weakReference.get();
            if (pVar == null) {
                copyOnWriteArrayList.remove(weakReference);
            } else {
                pVar.f();
            }
        }
        r();
    }

    /* JADX WARN: Removed duplicated region for block: B:11:0x0018  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean p(android.view.MenuItem r6, j.l r7, int r8) {
        /*
            r5 = this;
            j.k r6 = (j.k) r6
            r0 = 0
            if (r6 == 0) goto Laf
            boolean r1 = r6.isEnabled()
            if (r1 != 0) goto Ld
            goto Laf
        Ld:
            android.view.MenuItem$OnMenuItemClickListener r1 = r6.f5116p
            r2 = 1
            if (r1 == 0) goto L1a
            boolean r1 = r1.onMenuItemClick(r6)
            if (r1 == 0) goto L1a
        L18:
            r1 = r2
            goto L36
        L1a:
            j.j r1 = r6.f5114n
            boolean r3 = r1.e(r1, r6)
            if (r3 == 0) goto L23
            goto L18
        L23:
            android.content.Intent r3 = r6.f5107g
            if (r3 == 0) goto L35
            android.content.Context r1 = r1.f5081a     // Catch: android.content.ActivityNotFoundException -> L2d
            r1.startActivity(r3)     // Catch: android.content.ActivityNotFoundException -> L2d
            goto L18
        L2d:
            r1 = move-exception
            java.lang.String r3 = "MenuItemImpl"
            java.lang.String r4 = "Can't find activity to handle intent; ignoring"
            android.util.Log.e(r3, r4, r1)
        L35:
            r1 = r0
        L36:
            int r3 = r6.f5124y
            r3 = r3 & 8
            if (r3 == 0) goto L4b
            android.view.View r3 = r6.f5125z
            if (r3 == 0) goto L4b
            boolean r6 = r6.expandActionView()
            r1 = r1 | r6
            if (r1 == 0) goto Lae
            r5.c(r2)
            goto Lae
        L4b:
            boolean r3 = r6.hasSubMenu()
            if (r3 != 0) goto L59
            r6 = r8 & 1
            if (r6 != 0) goto Lae
            r5.c(r2)
            goto Lae
        L59:
            r8 = r8 & 4
            if (r8 != 0) goto L60
            r5.c(r0)
        L60:
            boolean r8 = r6.hasSubMenu()
            if (r8 != 0) goto L74
            j.t r8 = new j.t
            android.content.Context r3 = r5.f5081a
            r8.<init>(r3, r5, r6)
            r6.f5115o = r8
            java.lang.CharSequence r3 = r6.e
            r8.setHeaderTitle(r3)
        L74:
            j.t r6 = r6.f5115o
            java.util.concurrent.CopyOnWriteArrayList r8 = r5.f5097r
            boolean r3 = r8.isEmpty()
            if (r3 == 0) goto L7f
            goto La8
        L7f:
            if (r7 == 0) goto L85
            boolean r0 = r7.k(r6)
        L85:
            java.util.Iterator r7 = r8.iterator()
        L89:
            boolean r3 = r7.hasNext()
            if (r3 == 0) goto La8
            java.lang.Object r3 = r7.next()
            java.lang.ref.WeakReference r3 = (java.lang.ref.WeakReference) r3
            java.lang.Object r4 = r3.get()
            j.p r4 = (j.p) r4
            if (r4 != 0) goto La1
            r8.remove(r3)
            goto L89
        La1:
            if (r0 != 0) goto L89
            boolean r0 = r4.k(r6)
            goto L89
        La8:
            r1 = r1 | r0
            if (r1 != 0) goto Lae
            r5.c(r2)
        Lae:
            return r1
        Laf:
            return r0
        */
        throw new UnsupportedOperationException("Method not decompiled: j.j.p(android.view.MenuItem, j.l, int):boolean");
    }

    @Override // android.view.Menu
    public final boolean performIdentifierAction(int i4, int i5) {
        return p(findItem(i4), null, i5);
    }

    @Override // android.view.Menu
    public final boolean performShortcut(int i4, KeyEvent keyEvent, int i5) {
        k kVarG = g(i4, keyEvent);
        boolean zP = kVarG != null ? p(kVarG, null, i5) : false;
        if ((i5 & 2) != 0) {
            c(true);
        }
        return zP;
    }

    public final void q(int i4, CharSequence charSequence, int i5, View view) {
        if (view != null) {
            this.f5091l = null;
        } else {
            if (i4 > 0) {
                this.f5091l = this.f5082b.getText(i4);
            } else if (charSequence != null) {
                this.f5091l = charSequence;
            }
            if (i5 > 0) {
                r.h.getDrawable(this.f5081a, i5);
            }
        }
        o(false);
    }

    public final void r() {
        this.f5092m = false;
        if (this.f5093n) {
            this.f5093n = false;
            o(this.f5094o);
        }
    }

    @Override // android.view.Menu
    public final void removeGroup(int i4) {
        ArrayList arrayList = this.f5085f;
        int size = arrayList.size();
        int i5 = 0;
        int i6 = 0;
        while (true) {
            if (i6 >= size) {
                i6 = -1;
                break;
            } else if (((k) arrayList.get(i6)).f5103b == i4) {
                break;
            } else {
                i6++;
            }
        }
        if (i6 >= 0) {
            int size2 = arrayList.size() - i6;
            while (true) {
                int i7 = i5 + 1;
                if (i5 >= size2 || ((k) arrayList.get(i6)).f5103b != i4) {
                    break;
                }
                if (i6 >= 0) {
                    ArrayList arrayList2 = this.f5085f;
                    if (i6 < arrayList2.size()) {
                        arrayList2.remove(i6);
                    }
                }
                i5 = i7;
            }
            o(true);
        }
    }

    @Override // android.view.Menu
    public final void removeItem(int i4) {
        ArrayList arrayList = this.f5085f;
        int size = arrayList.size();
        int i5 = 0;
        while (true) {
            if (i5 >= size) {
                i5 = -1;
                break;
            } else if (((k) arrayList.get(i5)).f5102a == i4) {
                break;
            } else {
                i5++;
            }
        }
        if (i5 >= 0) {
            ArrayList arrayList2 = this.f5085f;
            if (i5 >= arrayList2.size()) {
                return;
            }
            arrayList2.remove(i5);
            o(true);
        }
    }

    public final void s() {
        if (this.f5092m) {
            return;
        }
        this.f5092m = true;
        this.f5093n = false;
        this.f5094o = false;
    }

    @Override // android.view.Menu
    public final void setGroupCheckable(int i4, boolean z4, boolean z5) {
        ArrayList arrayList = this.f5085f;
        int size = arrayList.size();
        for (int i5 = 0; i5 < size; i5++) {
            k kVar = (k) arrayList.get(i5);
            if (kVar.f5103b == i4) {
                kVar.f5123x = (kVar.f5123x & (-5)) | (z5 ? 4 : 0);
                kVar.setCheckable(z4);
            }
        }
    }

    @Override // android.view.Menu
    public void setGroupDividerEnabled(boolean z4) {
        this.f5099t = z4;
    }

    @Override // android.view.Menu
    public final void setGroupEnabled(int i4, boolean z4) {
        ArrayList arrayList = this.f5085f;
        int size = arrayList.size();
        for (int i5 = 0; i5 < size; i5++) {
            k kVar = (k) arrayList.get(i5);
            if (kVar.f5103b == i4) {
                kVar.setEnabled(z4);
            }
        }
    }

    @Override // android.view.Menu
    public final void setGroupVisible(int i4, boolean z4) {
        ArrayList arrayList = this.f5085f;
        int size = arrayList.size();
        boolean z5 = false;
        for (int i5 = 0; i5 < size; i5++) {
            k kVar = (k) arrayList.get(i5);
            if (kVar.f5103b == i4) {
                int i6 = kVar.f5123x;
                int i7 = (i6 & (-9)) | (z4 ? 0 : 8);
                kVar.f5123x = i7;
                if (i6 != i7) {
                    z5 = true;
                }
            }
        }
        if (z5) {
            o(true);
        }
    }

    @Override // android.view.Menu
    public void setQwertyMode(boolean z4) {
        this.f5083c = z4;
        o(false);
    }

    @Override // android.view.Menu
    public final int size() {
        return this.f5085f.size();
    }

    @Override // android.view.Menu
    public final MenuItem add(int i4) {
        return a(0, 0, 0, this.f5082b.getString(i4));
    }

    @Override // android.view.Menu
    public final SubMenu addSubMenu(int i4) {
        return addSubMenu(0, 0, 0, this.f5082b.getString(i4));
    }

    @Override // android.view.Menu
    public final MenuItem add(int i4, int i5, int i6, CharSequence charSequence) {
        return a(i4, i5, i6, charSequence);
    }

    @Override // android.view.Menu
    public final SubMenu addSubMenu(int i4, int i5, int i6, CharSequence charSequence) {
        k kVarA = a(i4, i5, i6, charSequence);
        t tVar = new t(this.f5081a, this, kVarA);
        kVarA.f5115o = tVar;
        tVar.setHeaderTitle(kVarA.e);
        return tVar;
    }

    @Override // android.view.Menu
    public final MenuItem add(int i4, int i5, int i6, int i7) {
        return a(i4, i5, i6, this.f5082b.getString(i7));
    }

    @Override // android.view.Menu
    public final SubMenu addSubMenu(int i4, int i5, int i6, int i7) {
        return addSubMenu(i4, i5, i6, this.f5082b.getString(i7));
    }

    public j j() {
        return this;
    }
}
