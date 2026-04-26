package k;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.widget.HeaderViewListAdapter;
import android.widget.ListAdapter;
import androidx.appcompat.view.menu.ListMenuItemView;

/* JADX INFO: loaded from: classes.dex */
public final class M extends AbstractC0474B {

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final int f5311t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final int f5312u;
    public L v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public j.k f5313w;

    public M(Context context, boolean z4) {
        super(context, z4);
        if (1 == context.getResources().getConfiguration().getLayoutDirection()) {
            this.f5311t = 21;
            this.f5312u = 22;
        } else {
            this.f5311t = 22;
            this.f5312u = 21;
        }
    }

    @Override // k.AbstractC0474B, android.view.View
    public final boolean onHoverEvent(MotionEvent motionEvent) {
        j.h hVar;
        int headersCount;
        int iPointToPosition;
        int i4;
        if (this.v != null) {
            ListAdapter adapter = getAdapter();
            if (adapter instanceof HeaderViewListAdapter) {
                HeaderViewListAdapter headerViewListAdapter = (HeaderViewListAdapter) adapter;
                headersCount = headerViewListAdapter.getHeadersCount();
                hVar = (j.h) headerViewListAdapter.getWrappedAdapter();
            } else {
                hVar = (j.h) adapter;
                headersCount = 0;
            }
            j.k item = (motionEvent.getAction() == 10 || (iPointToPosition = pointToPosition((int) motionEvent.getX(), (int) motionEvent.getY())) == -1 || (i4 = iPointToPosition - headersCount) < 0 || i4 >= hVar.getCount()) ? null : hVar.getItem(i4);
            j.k kVar = this.f5313w;
            if (kVar != item) {
                j.j jVar = hVar.f5075a;
                if (kVar != null) {
                    this.v.l(jVar, kVar);
                }
                this.f5313w = item;
                if (item != null) {
                    this.v.a(jVar, item);
                }
            }
        }
        return super.onHoverEvent(motionEvent);
    }

    @Override // android.widget.ListView, android.widget.AbsListView, android.view.View, android.view.KeyEvent.Callback
    public final boolean onKeyDown(int i4, KeyEvent keyEvent) {
        ListMenuItemView listMenuItemView = (ListMenuItemView) getSelectedView();
        if (listMenuItemView != null && i4 == this.f5311t) {
            if (listMenuItemView.isEnabled() && listMenuItemView.getItemData().hasSubMenu()) {
                performItemClick(listMenuItemView, getSelectedItemPosition(), getSelectedItemId());
            }
            return true;
        }
        if (listMenuItemView == null || i4 != this.f5312u) {
            return super.onKeyDown(i4, keyEvent);
        }
        setSelection(-1);
        ((j.h) getAdapter()).f5075a.c(false);
        return true;
    }

    public void setHoverListener(L l2) {
        this.v = l2;
    }

    @Override // k.AbstractC0474B, android.widget.AbsListView
    public /* bridge */ /* synthetic */ void setSelector(Drawable drawable) {
        super.setSelector(drawable);
    }
}
